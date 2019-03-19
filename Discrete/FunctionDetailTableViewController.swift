//
//  FunctionDetailTableViewController.swift
//  Discrete
//
//  Created by Sami Yrjänheikki on 19/03/2019.
//  Copyright © 2019 Sami Yrjänheikki. All rights reserved.
//

import UIKit
import SafariServices

class FunctionDetailTableViewController: UITableViewController {

    var function: FunctionDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return function?.url == nil ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 1
        default: return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NameCell", for: indexPath)
                cell.detailTextLabel?.text = function?.name
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath)
                cell.detailTextLabel?.text = function?.description
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "URLCell", for: indexPath)
            cell.textLabel?.text = "Learn more..."
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let urlString = function?.url, let url = URL(string: urlString) {
            let safari = SFSafariViewController(url: url)
            safari.preferredControlTintColor = UIApplication.shared.keyWindow?.tintColor
            present(safari, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
