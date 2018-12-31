//
//  OptionsTableViewController.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 29/12/2018.
//  Copyright © 2018 Sami Yrjänheikki. All rights reserved.
//

import UIKit

class OptionsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.navigationItem.title = "Options"
        super.viewWillAppear(animated)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Basic", for: indexPath)

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: cell.textLabel?.text = "Automatic"
            case 1: cell.textLabel?.text = "Fraction"
            case 2: cell.textLabel?.text = "Decimal"
            default: break
            }
            cell.accessoryType = Preferences.shared.displayMode.rawValue == indexPath.row ? .checkmark : .none
            default: break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let newMode = Preferences.DisplayMode(rawValue: indexPath.row) {
                Preferences.shared.displayMode = newMode
            }
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        default: break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Display mode"
        default: return nil
        }
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: return "Irrational numbers will always be displayed as a decimal number."
        default: return nil
        }
    }
}
