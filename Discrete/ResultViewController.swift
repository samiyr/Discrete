//
//  ResultViewController.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 01/01/2019.
//  Copyright © 2019 Sami Yrjänheikki. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var expressionLabel: UILabel!
    @IBOutlet weak var resultTextView: UITextView!
    var expression: String?
    var result: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        expressionLabel.text = expression
        resultTextView.text = result
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        navigationItem.rightBarButtonItem = shareButton
    }
    @objc func share() {
        guard let expression = expression else { return }
        var sign = "="
        if result?.contains("≈") ?? false {
            sign = "≈"
        }
        guard let resultString = result?.components(separatedBy: " \(sign) ").last else { return }
        let sheet = UIActivityViewController(activityItems: ["\(expression) \(sign) \(resultString)"], applicationActivities: nil)
        sheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(sheet, animated: true, completion: nil)
    }
}
