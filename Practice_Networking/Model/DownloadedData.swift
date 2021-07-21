//
//  DownloadedData.swift
//  Practice_Networking
//
//  Created by Alex Han on 18.07.2021.
//  Copyright © 2021 NIX Solitions. All rights reserved.
//

struct DownloadedData: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
    
//    init(json: [String : Any]) {
//        self.userID = json["userId"] as? Int ?? 0
//        self.id = json["id"] as? Int ?? 0
//        self.title = json["title"] as? String ?? ""
//        self.body = json["body"] as? String ?? ""
//    }
}
