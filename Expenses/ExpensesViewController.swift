//
//  ExpensesViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import UIKit
import os.log

class ExpensesViewController: UITableViewController {
    
    var selectedExpense : Expense?
    
    var expenses = [Expense]()
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("expenses")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        if let savedExpenses = loadExpenses() {
            expenses += savedExpenses
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let expenseCell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as? ExpenseCell else {
            fatalError("The dequeued cell is not an instance of ExpenseCell.")
        }
        
        let expense = expenses[indexPath.row]
        expenseCell.amountLabel.text = expense.amount.currencyInputFormatting()
        expenseCell.dateLabel.text = expense.date.asLocaleDateString
        expenseCell.categoryLabel.text = expense.category.name
        expenseCell.commentLabel.text = expense.comment
        return expenseCell
    }

    /* To be used to show sum of costs up to date selected
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // os_log("Scrolled to %f", scrollView.contentOffset.y)
        let firstVisibleIndexPath = self.tableView.indexPathsForVisibleRows?.first
        print("First visible cell row=\(firstVisibleIndexPath?.row)")
    } */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
        case "AddExpense":
            os_log("Adding a new expense.", log: OSLog.default, type: .debug)
        case "EditExpense":
            guard let expsenseDetailsViewController = segue.destination as? ExpenseDetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedExpenseCell = sender as? ExpenseCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            guard let indexPath = tableView.indexPath(for: selectedExpenseCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedExpense = expenses[indexPath.row]
            expsenseDetailsViewController.expense = selectedExpense

        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier)")
        }
    }
    
    private func saveExpenses() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(expenses, toFile: ExpensesViewController.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Expenses successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save expenses...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadExpenses() -> [Expense]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: ExpensesViewController.ArchiveURL.path) as? [Expense]
    }
}

extension ExpensesViewController {
    @IBAction func cancelToExpensesViewController(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func saveExpenseDetail(_ segue: UIStoryboardSegue) {
        if let expenseDetailsViewController = segue.source as? ExpenseDetailsViewController, let expense = expenseDetailsViewController.expense {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                expenses[selectedIndexPath.row] = expense
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: 0, section: 0)
                expenses.insert(expense, at: 0)
                tableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.automatic)
            }
            saveExpenses()
        }
    }
}
