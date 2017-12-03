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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let expenseCell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as! ExpenseCell
        
        let expense = expenses[indexPath.row]
        expenseCell.expense = expense
        return expenseCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "EditExpense", sender: indexPath)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // os_log("Scrolled to %f", scrollView.contentOffset.y)
        let firstVisibleIndexPath = self.tableView.indexPathsForVisibleRows?.first
        print("First visible cell row=\(firstVisibleIndexPath?.row)")
    }

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
        }
    }
}
