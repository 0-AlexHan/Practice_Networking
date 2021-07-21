//
//  ViewController.swift
//  Practice_Networking
//
//  Created by anna on 8/15/19.
//  Copyright © 2019 NIX Solitions. All rights reserved.
//

import UIKit

class NetworkViewController: UIViewController {
    
    private var choosenImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkManager.shared().delegate = self
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Pick Image",
                                                              style: .plain,
                                                              target: self,
                                                              action: #selector(addDidTap))]
    }
    
    @objc func addDidTap() {
        ImagePickerManager().pickImage(self) { image in
            self.choosenImage = image
        }
    }
    
    @IBAction func didPostImage(_ sender: Any) {
        
        guard let image = choosenImage else {
            print("no image picked")
            return
        }
        
        NetworkManager.shared().uploadImageToImgur(image: image)
    }
    @IBAction func postInBackground(_ sender: Any) {
        
        guard let image = choosenImage else {
            print("no image picked")
            return
        }
        
        NetworkManager.shared().backgroundUpload(image: image)
        
        
        
    }
}

extension NetworkViewController: URLSessionDelegate, URLSessionTaskDelegate, NetworkManagerDelegate {
    
    func backgroundUpload(request: URLRequest) {
        let backgroundID = "uploadBigSize"
        guard let url = request.url else {
            return
        }
        
        let image: UIImage = #imageLiteral(resourceName: "unknown")
        let data = image.jpegData(compressionQuality: 1.0)?.base64EncodedData()
        let tempDir = FileManager.default.temporaryDirectory
        let localPath = tempDir.appendingPathComponent("temp")
        try? data?.write(to: localPath)
        
        let config = URLSessionConfiguration.background(withIdentifier: backgroundID)
        let session = URLSession(configuration: config,
                                 delegate:  self,
                                 delegateQueue: nil)
        let task = session.uploadTask(with: request, fromFile: localPath)
        task.resume()
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let completionHandler = NetworkManager.shared().savedCompletionHandler?() {
            DispatchQueue.main.async {
                completionHandler
                print("asdasdasdasdasd")
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print(task.response)
        }
    }
}
