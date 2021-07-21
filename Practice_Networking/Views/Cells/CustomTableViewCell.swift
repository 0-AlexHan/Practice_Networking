//
//  CustomTableViewCell.swift
//  Practice_Networking
//
//  Created by Alex Han on 18.07.2021.
//  Copyright © 2021 NIX Solitions. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet private weak var userIdLabel: UILabel!
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var titleTextView: UITextView!        

    
    func setCell(withData data: DownloadedData) {
        self.userIdLabel.text = "User ID: " + String(data.userId)
        self.idLabel.text = "ID: " + String(data.id)
        self.titleTextView.text = "Title: " + data.title
    }
    
}
