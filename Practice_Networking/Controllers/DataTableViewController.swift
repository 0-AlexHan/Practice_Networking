//
//  DataTableViewController.swift
//  Practice_Networking
//
//  Created by Alex Han on 18.07.2021.
//  Copyright © 2021 NIX Solitions. All rights reserved.
//

import UIKit

class DataTableViewController: UITableViewController {

    private var arrayOfAll = [DownloadedData]()
    let test = [1, 2, 3, 4, 5]
    private let cellID = String(describing: CustomTableViewCell.self)
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: cellID, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellID)
        
        getDataFromServer()
        
      
    }
    
    func getDataFromServer() {
        NetworkManager.shared()
            .getAllDataFromServer { [weak self] data in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.arrayOfAll = data
                    self.tableView.reloadData()
                }
                
            } onFailure: { error, statusCode in
                print("Error = \(error.localizedDescription)", "with code: \(statusCode)")
            }

    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 100
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfAll.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let customCell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        let data = arrayOfAll[indexPath.row]
        customCell.setCell(withData: data)
        return customCell
    }
    
}
