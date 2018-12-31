//
//  MainTableViewController.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 26/12/2018.
//  Copyright © 2018 Sami Yrjänheikki. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {

    let fakeField = UITextField()
    @IBOutlet weak var entryField: UITextField!
    
    @IBOutlet weak var inputToolbar: UIToolbar!
    @IBOutlet weak var auxiliaryToolbar: UIToolbar!
    
    var expressions = [String]()
    var results = [BigDouble]()
    var decimalPlaces = [Int]()
    var variables = [BigDouble]()
    var errors = [String : String]()
    var errorRanges = [String : Range<Int>]()
    
    var timer: Timer?
    
    @IBOutlet var inputAccessory: UIView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var currentWorkItem: Thread?
    var isExecuting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fakeField.inputAccessoryView = inputAccessory
        fakeField.becomeFirstResponder()
        fakeField.delegate = self
        fakeField.keyboardType = entryField.keyboardType
        view.addSubview(fakeField)
        
        entryField.becomeFirstResponder()
        entryField.delegate = self
        
        let copyExpressionMenu = UIMenuItem(title: "Copy Expression", action: #selector(copyExpression))
        let copyValueMenu = UIMenuItem(title: "Copy Value", action: #selector(copyValue))
        UIMenuController.shared.menuItems = [copyExpressionMenu, copyValueMenu]
        UIMenuController.shared.update()
        
        auxiliaryToolbar.tintColor = UIApplication.shared.keyWindow?.tintColor
        
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
    
    @IBAction func insertChar(_ sender: UIBarButtonItem) {
        entryField.text = (entryField.text ?? "") + (sender.title ?? "")
    }
    @IBAction func cancelCurrent(_ sender: Any) {
        Thread.exit()
    }

    @objc func copyExpression() {}
    @objc func copyValue() {}
    @IBOutlet weak var clearAllButton: UIBarButtonItem!
    @IBAction func clearAll(_ sender: Any) {
        let sheet = UIAlertController(title: "Clear history?", message: "This action cannot be undone", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Clear history", style: .destructive, handler: { _ in
            self.expressions.removeAll()
            self.results.removeAll()
            self.variables.removeAll()
            self.errors.removeAll()
            self.errorRanges.removeAll()
            self.tableView.reloadData()
            self.clearAllButton.isEnabled = false
        }))
        present(sheet, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expressions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let error = errors["\(indexPath.row)"] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell", for: indexPath)
            if let range = errorRanges["\(indexPath.row)"] {
                let nsRange = NSRange(location: range.lowerBound, length: range.upperBound - range.lowerBound)
                let attributedText = NSMutableAttributedString(string: expressions[indexPath.row])
                attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
                attributedText.addAttribute(.underlineColor, value: UIColor.red, range: nsRange)
                cell.textLabel?.attributedText = attributedText
            } else {
                cell.textLabel?.text = expressions[indexPath.row]
            }
            cell.detailTextLabel?.text = error
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = expressions[indexPath.row]
            let variable = "\(variables.count)"
            let result = results[indexPath.row]
            let sign = result.isApproximation ? "≈" : "="
            // cell.accessoryType = result.isApproximation ? .disclosureIndicator : .none
            var resultString = "\(result)"
            if result.isApproximation {
                resultString = result.decimalApproximation(to: decimalPlaces[indexPath.row]).decimal
            }
            cell.detailTextLabel?.text = "[\(variable)] \(sign) \(resultString)"
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*if errors["\(indexPath.row)"] == nil {
            decimalPlaces[indexPath.row] += 10
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }*/
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let error = errors["\(indexPath.row)"] {
            let resultAction = UIContextualAction(style: .normal, title: "Copy error") { (_, _, completion) in
                let expression = self.expressions[indexPath.row]
                UIPasteboard.general.string = "Expression: \(expression)\nError: \(error)"
                completion(true)
            }
            resultAction.backgroundColor = UIColor.purple
            return UISwipeActionsConfiguration(actions: [resultAction])
        } else {
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
            resultAction.backgroundColor = UIColor.purple
            return UISwipeActionsConfiguration(actions: [resultAction])
        }
    }
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let _ = errors["\(indexPath.row)"] {
            return nil
        }
        let expressionAction = UIContextualAction(style: .normal, title: "Use expression") { (_, _, completion) in
            var text = self.entryField.text
            text?.append(self.expressions[indexPath.row])
            self.entryField.text = text
            completion(true)
        }
        expressionAction.backgroundColor = UIColor.blue
        return UISwipeActionsConfiguration(actions: [expressionAction])
    }
    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copyExpression) || action == #selector(copyValue)
    }
    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        switch action {
        case #selector(copyExpression):
            UIPasteboard.general.string = expressions[indexPath.row]
        case #selector(copyValue):
            UIPasteboard.general.string = results[indexPath.row].description
        default:
            return
        }
    }
    
    let executionQueue = DispatchQueue(label: "execution queue", qos: .userInteractive, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    func parseExpression(_ expression: String?, completion: @escaping (Bool) -> Void) {
        guard let expression = expression, !expression.isEmpty else {
            if let previous = expressions.last {
                self.parseExpression(previous, completion: completion)
            }
            completion(false)
            return
        }
        let thread = Thread {
            var flag: Bool
            do {
                var substitutions = [String : BigDouble]()
                for i in 0..<self.variables.count {
                    substitutions["[\(i + 1)]"] = self.variables[i]
                }
                substitutions["Ans"] = self.variables.last
                let evaluation = try expression.evaluate(substitutions)
                self.results.append(evaluation)
                self.variables.append(evaluation)
                flag = true
            } catch {
                var description = error.localizedDescription
                let index = "\(self.expressions.count)"
                if let error = error as? MathParserError {
                    switch error.kind {
                    case .cannotParseNumber: description = "Cannot parse number"
                    case .cannotParseHexNumber: description = "Cannot parse hex number"
                    case .cannotParseOctalNumber: description = "Cannot parse octal number"
                    case .cannotParseFractionalNumber: description = "Cannot parse fraction"
                    case .cannotParseExponent: description = "Cannot parse exponent"
                    case .cannotParseIdentifier: description = "Cannot parse identifier"
                    case .cannotParseVariable: description = "Cannot parse variable"
                    case .cannotParseQuotedVariable:description = "Cannot parse variable"
                    case .cannotParseOperator: description = "Cannot parse operator"
                    case .zeroLengthVariable: description = "Zero length variable"
                    case .cannotParseLocalizedNumber: description = "Cannot parse number"
                    case .unknownOperator: description = "Unknown operator"
                    case .ambiguousOperator: description = "Ambiguous operator"
                    case .missingOpenParenthesis: description = "Missing open parenthesis"
                    case .missingCloseParenthesis: description = "Missing closing parenthesis"
                    case .emptyFunctionArgument: description = "Empty function argument"
                    case .emptyGroup: description = "Empty group"
                    case .invalidFormat: description = "Invalid format"
                    case .missingLeftOperand(let operand): description = "Missing left operand '\(operand.description)'"
                    case .missingRightOperand(let operand): description = "Missing right operand '\(operand.description)'"
                    case .unknownFunction(let function): description = "Unknown function '\(function)'"
                    case .unknownVariable(let variable): description = "Unknown variable '\(variable)'"
                    case .divideByZero: description = "Division by zero"
                    case .invalidArguments: description = "Invalid arguments"
                    }
                    self.errorRanges[index] = error.range
                }
                self.errors[index] = description
                self.results.append(0)
                print(error)
                flag = false
            }
            DispatchQueue.main.async {
                self.expressions.append(expression)
                let newIndexPath = IndexPath(row: self.tableView.numberOfRows(inSection: 0), section: 0)
                self.tableView.insertRows(at: [newIndexPath], with: .automatic)
                self.tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
                self.clearAllButton.isEnabled = true
                self.cancelButton.isEnabled = false
                self.isExecuting = false
                self.timer?.invalidate()
                self.timer = nil
                completion(flag)
            }

        }
        currentWorkItem = thread
        if !Preferences.shared.computationTimeWarning {
            timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(showComputationTimeWarning), userInfo: nil, repeats: false)
        }
        thread.start()
        isExecuting = true
        self.decimalPlaces.append(12)
        cancelButton.isEnabled = true
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
        parseExpression(textField.text) { (success) in
            if success {
                textField.text = nil
            }
        }
        return true
    }
}

