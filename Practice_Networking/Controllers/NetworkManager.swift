//
//  NetworkManager.swift
//  Practice_Networking
//
//  Created by Alex Han on 17.07.2021.
//  Copyright © 2021 NIX Solitions. All rights reserved.
//

import Foundation
import UIKit

protocol NetworkManagerDelegate {
    func backgroundUpload(request: URLRequest)
}

class NetworkManager {
    
    private static var uniqueInstance: NetworkManager?
    private let getURL: URL?
    private let postURL: URL?
    var savedCompletionHandler: ( () -> Void )?
    
    var delegate: NetworkManagerDelegate?
    
    private init() {
        let getUrlString = "https://jsonplaceholder.typicode.com/posts"
        let postUrlString = "https://api.imgur.com/3/image"
        
        self.getURL = URL(string: getUrlString)
        self.postURL = URL(string: postUrlString)
    }
    
    static func shared() -> NetworkManager {
        if uniqueInstance == nil {
            uniqueInstance = NetworkManager()
        }
        
        return uniqueInstance!
    }
    
    func callPostRequest() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            return
        }
        
        let userData = ["Course" : "Networking",
                        "Task" : "GET and POST requests"]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: userData, options: [])
        else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, responce, error) in
            guard let responce = responce,
                  let data = data
            else {
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error)
            }
        }.resume()
    }
    func getAllDataFromServer(onSuccess: @escaping ( [DownloadedData] ) -> Void,
                              onFailure: (Error, Int) -> Void) {
        
        guard let url = self.getURL else {
            print("URL is nil")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) { (data, responce, error) in
            guard let data = data
            else {
                return
            }
            
            do {
                let json = try JSONDecoder().decode([DownloadedData].self, from: data)
                onSuccess(json)
            } catch {
                print(error)
            }
            
        }.resume()
    }
    
    func getBase64Image(image: UIImage, complete: @escaping (String?) -> ()) {
        DispatchQueue.main.async {
            let imageData = image.jpegData(compressionQuality: 1.0)
            let base64Image = imageData?.base64EncodedString(options: .lineLength64Characters)
            complete(base64Image)
        }
    }
    
    func uploadImageToImgur(image: UIImage) {
        getBase64Image(image: image) { [weak self] base64Image in
            let boundary = "Boundary-\(UUID().uuidString)"
            let clientID = "5af4a79c42ea7df"
            
            guard let self = self, let postUrl = self.postURL else {
                return
            }
            var request = URLRequest(url: postUrl)
            request.addValue("Client-ID \(clientID)", forHTTPHeaderField: "Authorization")
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            request.httpMethod = "POST"
            
            var body = ""
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"image\""
            body += "\r\n\r\n\(base64Image ?? "")\r\n"
            body += "--\(boundary)--\r\n"
            let postData = body.data(using: .utf8)
            
            request.httpBody = postData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("error: \(error)")
                    return
                }
                guard let response = response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    print("server error: ", response)
                    return
                }
                if let mimeType = response.mimeType, mimeType == "application/json", let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Results: \(dataString)")
                    
                    
                    do {
                        guard let parsedResult: [String : Any] = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any] else {
                            assertionFailure("An error occured")
                            return
                        }
                        if let dataJson = parsedResult["data"] as? [String : Any] {
                            print("Link ->>> : \(dataJson["link"] as? String ?? "There is no link")")
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    func backgroundUpload(image: UIImage) {
        getBase64Image(image: image) { [weak self] base64Image in
            let boundary = "Boundary-\(UUID().uuidString)"
            let clientID = "5af4a79c42ea7df"
            
            guard let self = self, let postUrl = self.postURL else {
                return
            }
            var request = URLRequest(url: postUrl)
            request.addValue("Client-ID \(clientID)", forHTTPHeaderField: "Authorization")
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            request.httpMethod = "POST"
            
            var body = ""
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"image\""
            body += "\r\n\r\n\(base64Image ?? "")\r\n"
            body += "--\(boundary)--\r\n"
            let postData = body.data(using: .utf8)
            
            request.httpBody = postData
            
            guard let delegate = self.delegate else {
                print("asdasd")
                return
            }
            
            delegate.backgroundUpload(request: request)
        }
    }
}
