//
//  InfoViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 01.01.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBAction func exportDataPressed(_ sender: UIButton) {
        let userDocumentsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = userDocumentsFolder.appending("/Expenses.csv")
        let fileURL = URL(fileURLWithPath: path)
        var csv = ""
        let dateFormat = ISO8601DateFormatter()
        for section in 0..<(Model.sharedInstance.expenseByDateModel!.sectionCount()) {
            for row in 0..<(Model.sharedInstance.expenseByDateModel!.expensesCount(inSection: section)) {
                let expense = Model.sharedInstance.expenseByDateModel!.expense(inSection: section, row: row)
                let dateString = dateFormat.string(from: expense.date)
                let amountString = String(expense.amount)
                csv += "\(dateString)\t\(amountString)\t\(expense.account)\t\(expense.category)\t\(expense.project)\t\(expense.comment)\t \n"
            }
        }
        do {
            try csv.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            ViewControllerUtils.showAlert(title: "Expenses exported", message: "Saved to Expenses.csv.", viewController: self)
        } catch {
            ViewControllerUtils.showAlert(title: "Error exporting Expenses", message: "Saving to Expenses.csv failed.", viewController: self)
        }
    }
    
    @IBAction func importDataPressed(_ sender: UIButton) {
        let userDocumentsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = userDocumentsFolder.appending("/Expenses.csv")
        let fileURL = URL(fileURLWithPath: path)
        do {
            let newExpenses = [Expense]()
            let contents = try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
            print(contents)
            let rows = contents.components(separatedBy: "\n")
            let dateFormat = ISO8601DateFormatter()
            for row in rows {
                let columns = row.components(separatedBy: "\t")
                if columns.count >= 6 {
                    let date = dateFormat.date(from: columns[0])
                    let amount = (columns[1] as NSString).floatValue
                    let account = columns[2]
                    let category = columns[3]
                    let project = columns[4]
                    let comment = columns[5]
                    let expense = Expense(date: date!, category: category, account: account, project: project, amount: amount, comment: comment)
                    Model.sharedInstance.updateExpense(expense: expense)
                }
            }
            ViewControllerUtils.showAlert(title: "Import succesful", message: "Imported \((newExpenses.count)) expenses.", viewController: self)
        } catch {
            ViewControllerUtils.showAlert(title: "Error importing Expenses", message: "Importing from Expenses.csv failed.", viewController: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
