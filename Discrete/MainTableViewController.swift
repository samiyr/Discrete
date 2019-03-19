//
//  MainTableViewController.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 26/12/2018.
//  Copyright © 2018 Sami Yrjänheikki. All rights reserved.
//

import UIKit
import Computation
import BigInt

class MainTableViewController: UITableViewController {

    let fakeField = UITextField()
    @IBOutlet weak var entryField: UITextField!
    
    @IBOutlet weak var inputToolbar: UIToolbar!
    @IBOutlet weak var auxiliaryToolbar: UIToolbar!
    
    var evaluations = [Evaluation]()
    var variables = [DiscreteInt]()
    
    var timer: Timer?
    
    @IBOutlet var inputAccessory: UIView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var currentWorkItem: DispatchWorkItem?
    var isExecuting = false
    
    var menlo: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont(name: "Menlo", size: 17)!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fakeField.inputAccessoryView = inputAccessory
        fakeField.becomeFirstResponder()
        fakeField.delegate = self
        fakeField.keyboardType = entryField.keyboardType
        view.addSubview(fakeField)
        
        entryField.becomeFirstResponder()
        entryField.delegate = self
        
        auxiliaryToolbar.tintColor = UIApplication.shared.keyWindow?.tintColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(thermalStateChanged), name: ProcessInfo.thermalStateDidChangeNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        fakeField.resignFirstResponder()
        entryField.resignFirstResponder()
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        fakeField.becomeFirstResponder()
        entryField.becomeFirstResponder()
        super.viewWillAppear(animated)
    }
    @objc func thermalStateChanged() {
        let state = ProcessInfo.processInfo.thermalState
        if state == .critical, !Preferences.shared.thermalOverride {
            ComputationLock.shared.requestLock()
            navigationItem.title = "Stopping..."
            let alert = UIAlertController(title: "Thermal alert", message: "The current computation has been stopped to prevent the device from overheating.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func insertChar(_ sender: UIBarButtonItem) {
        var insertion = sender.title ?? ""
        if insertion == "Ans" {
            insertion = "$Ans"
        }
        entryField.text = (entryField.text ?? "") + insertion
    }
    @IBAction func cancelCurrent(_ sender: Any) {
        let alert = UIAlertController(title: "Stop computation?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Stop", style: .default, handler: { _ in
            ComputationLock.shared.requestLock()
            self.navigationItem.title = "Stopping..."
        }))
        present(alert, animated: true, completion: nil)
    }

    @IBOutlet weak var clearAllButton: UIBarButtonItem!
    @IBAction func clearAll(_ sender: Any) {
        let sheet = UIAlertController(title: "Clear history?", message: "This action cannot be undone", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Clear history", style: .destructive, handler: { _ in
            self.evaluations.removeAll()
            self.variables.removeAll()
            self.tableView.reloadData()
            self.clearAllButton.isEnabled = false
        }))
        present(sheet, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "result", let destination = segue.destination as? ResultViewController, let indexPath = tableView.indexPathForSelectedRow, let cell = tableView.cellForRow(at: indexPath) {
            let evaluation = evaluations[indexPath.row]
            destination.expression = evaluation.expression
            if let result = evaluation.result, let variable = cell.detailTextLabel?.text?.components(separatedBy: " = ").first {
                let resultString = result.description
                destination.result = "\(variable) = \(resultString)"
            }
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return evaluations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        func applyFont(_ label: UILabel?) {
            label?.font = menlo
            label?.adjustsFontForContentSizeCategory = true
        }
        func applyFonts(_ labels: [UILabel?]) {
            labels.forEach { applyFont($0) }
        }
        let evaluation = evaluations[indexPath.row]
        if let result = evaluation.result {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            applyFonts([cell.textLabel, cell.detailTextLabel])
            cell.detailTextLabel?.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont(name: "Menlo-Bold", size: 17)!)
            cell.textLabel?.text = evaluation.expression
            let variable = "\(variables.count)"
            cell.accessoryType = .none
            var resultString = result.description
            if resultString.count > 52 {
                let start = resultString.startIndex
                let end = resultString.index(start, offsetBy: 52)
                resultString = String(resultString[start...end]) + "..."
                cell.accessoryType = .disclosureIndicator
            }
            cell.detailTextLabel?.text = "[\(variable)] = \(resultString)"
            return cell
        } else if let error = evaluation.error {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell", for: indexPath)
            applyFont(cell.textLabel)
            let range = error.range
                let nsRange = NSRange(location: range.lowerBound, length: range.upperBound - range.lowerBound)
                let attributedText = NSMutableAttributedString(string: evaluation.expression)
                attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
                attributedText.addAttribute(.underlineColor, value: cell.detailTextLabel?.textColor ?? UIColor.red, range: nsRange)
                cell.textLabel?.attributedText = attributedText
            
            cell.detailTextLabel?.text = error.description
            return cell
        }
        return UITableViewCell()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath), cell.accessoryType == .disclosureIndicator {
            performSegue(withIdentifier: "result", sender: self)
        }
        /*if errors["\(indexPath.row)"] == nil {
            decimalPlaces[indexPath.row] += 10
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }*/
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let evaluation = evaluations[indexPath.row]
        if let _ = evaluation.result {
            let resultAction = UIContextualAction(style: .normal, title: "Use result") { (_, _, completion) in
                if let cell = tableView.cellForRow(at: indexPath), let cellText = cell.detailTextLabel?.text {
                    var variable = ""
                    if let input = cellText.components(separatedBy: " = ").first {
                        variable = input
                    } else if let input = cellText.components(separatedBy: " ≈ ").first {
                        variable = input
                    } else {
                        completion(false)
                        return
                    }
                    var text = self.entryField.text
                    text?.append("$" + variable)
                    self.entryField.text = text
                    completion(true)
                } else {
                    completion(false)
                }
            }
            resultAction.backgroundColor = UIColor(named: "Purple")
            let copyAction = UIContextualAction(style: .normal, title: "Copy result") { (_, _, completion) in
                UIPasteboard.general.string = self.evaluations[indexPath.row].result?.description
                completion(true)
            }
            copyAction.backgroundColor = UIColor(named: "Green")
            return UISwipeActionsConfiguration(actions: [resultAction, copyAction])
        } else if let error = evaluation.error {
            let resultAction = UIContextualAction(style: .normal, title: "Copy error") { (_, _, completion) in
                let expression = self.evaluations[indexPath.row].expression
                UIPasteboard.general.string = "Expression: \(expression)\nError: \(error)"
                completion(true)
            }
            resultAction.backgroundColor = UIColor(named: "Purple")
            return UISwipeActionsConfiguration(actions: [resultAction])
        }
        return nil
    }
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let evaluation = evaluations[indexPath.row]
        if let _ = evaluation.error {
            return nil
        }
        let expressionAction = UIContextualAction(style: .normal, title: "Use expression") { (_, _, completion) in
            var text = self.entryField.text
            text?.append(evaluation.expression)
            self.entryField.text = text
            completion(true)
        }
        expressionAction.backgroundColor = UIColor(named: "Blue")
        let copyAction = UIContextualAction(style: .normal, title: "Copy expression") { (_, _, completion) in
            UIPasteboard.general.string = evaluation.expression
            completion(true)
        }
        copyAction.backgroundColor = UIColor(named: "Orange")
        return UISwipeActionsConfiguration(actions: [expressionAction, copyAction])
    }
    let executionQueue = DispatchQueue(label: "execution queue", qos: .userInteractive, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    func parseExpression(_ expression: String?, completion: @escaping (Bool) -> Void) {
        guard let expression = expression, !expression.isEmpty else {
            if let previous = evaluations.last {
                self.parseExpression(previous.expression, completion: completion)
            }
            completion(false)
            return
        }
        let item = DispatchWorkItem {
            var flag = false
            
            var substitutions = [String : DiscreteInt]()
            for i in 0..<self.variables.count {
                substitutions["[\(i + 1)]"] = self.variables[i]
            }
            substitutions["Ans"] = self.variables.last
            substitutions["Idx"] = DiscreteInt(self.variables.count)
            let evaluation = Evaluation(expression: expression, substitutions: substitutions)
            try? evaluation.evaluate()
            self.evaluations.append(evaluation)
            if let result = evaluation.result as? DiscreteInt {
                self.variables.append(result)
                flag = true
            }
            DispatchQueue.main.async {
                let newIndexPath = IndexPath(row: self.tableView.numberOfRows(inSection: 0), section: 0)
                self.tableView.insertRows(at: [newIndexPath], with: .automatic)
                self.tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
                self.clearAllButton.isEnabled = true
                self.cancelButton.isEnabled = false
                self.navigationItem.title = "Arbitrary"
                self.isExecuting = false
                self.timer?.invalidate()
                self.timer = nil
                ComputationLock.shared.removeLock()
                self.currentWorkItem = nil
                completion(flag)
            }

        }
        currentWorkItem = item
        if !Preferences.shared.computationTimeWarning {
            timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(showComputationTimeWarning), userInfo: nil, repeats: false)
        }
        executionQueue.async(execute: item)
        isExecuting = true
        cancelButton.isEnabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.isExecuting {
                self.navigationItem.title = "Computing..."
            }
        }
    }
    @objc func showComputationTimeWarning() {
        if Preferences.shared.computationTimeWarning { return }
        let alert = UIAlertController(title: "Warning", message: "The latest calculation has been running for 5 seconds. If you want, you can cancel the computation by tapping the ╳ on the right side of the screen near the keyboard. You will see this warning only once.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK, got it", style: .cancel, handler: { _ in
            self.timer?.invalidate()
            self.timer = nil
            Preferences.shared.computationTimeWarning = true
        }))
        alert.addAction(UIAlertAction(title: "Help", style: .default, handler: { _ in
            #warning("Incomplete implementation")
            self.timer?.invalidate()
            self.timer = nil
            Preferences.shared.computationTimeWarning = true
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension MainTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == fakeField {
            let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
            entryField.text = result
            entryField.becomeFirstResponder()
            return false
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        parseExpression(entryField.text) { (success) in
            if success {
                self.entryField.text = nil
            }
        }
        return true
    }
}

