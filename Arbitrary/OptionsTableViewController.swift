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
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3
        case 1: return 3
        case 2: return 2
        case 3: return 2
        default: return 0
        }
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
        case 1:
            switch indexPath.row {
            case 0: cell.textLabel?.text = "Automatic"
            case 1: cell.textLabel?.text = "Scientific"
            case 2: cell.textLabel?.text = "Decimal"
            default: break
            }
            cell.accessoryType = Preferences.shared.largeNumberDisplayMode.rawValue == indexPath.row ? .checkmark : .none
        case 2:
            switch indexPath.row {
            case 0: cell.textLabel?.text = "Radians"
            case 1: cell.textLabel?.text = "Degrees"
            default: break
            }
            cell.accessoryType = Preferences.shared.angleMode.rawValue == indexPath.row ? .checkmark : .none
        case 3:
            switch indexPath.row {
            case 0: cell.textLabel?.text = "Large (1/2)"
            case 1: cell.textLabel?.text = "Small (¹/₂)"
            default: break
            }
            cell.accessoryType = Preferences.shared.fractionDisplayMode.rawValue == indexPath.row ? .checkmark : .none
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
        case 1:
            if let newMode = Preferences.LargeNumberDisplayMode(rawValue: indexPath.row) {
                Preferences.shared.largeNumberDisplayMode = newMode
            }
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        case 2:
            if let newMode = Preferences.AngleMode(rawValue: indexPath.row) {
                Preferences.shared.angleMode = newMode
            }
            tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
        case 3:
            if let newMode = Preferences.FractionDisplayMode(rawValue: indexPath.row) {
                Preferences.shared.fractionDisplayMode = newMode
            }
            tableView.reloadSections(IndexSet(integer: 3), with: .automatic)
        default: break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Display mode"
        case 1: return "Large number display mode"
        case 2: return "Angle mode"
        case 3: return "Fraction display mode"
        default: return nil
        }
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: return "Irrational numbers will always be displayed as a decimal number."
        case 2: return "You can temporarely evaluate an expression as degrees by using the symbol °."
        default: return nil
        }
    }
}
