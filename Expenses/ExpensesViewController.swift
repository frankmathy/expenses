//
//  ExpensesViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import UIKit
import os.log
import Firebase

class ExpensesViewController: UITableViewController {
    
    var selectedExpense : Expense?
    
    var expenses = [Expense]()
    
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        user = User(uid: "FakeId", email: "hungry@person.food")
        let expensesRef = getExpensesDatabaseReference()
        expensesRef.queryOrdered(byChild: "date").observe(.value, with: { (snapshot) in
            var newExpenses: [Expense] = []
            for entry in snapshot.children {
                let expense = Expense(snapshot: entry as! DataSnapshot)
                newExpenses.append(expense)
            }
            self.expenses = newExpenses
            self.sortExpenses()
            self.tableView.reloadData()
        })
    }
    
    func getExpensesDatabaseReference() -> DatabaseReference {
        return Database.database().reference(withPath: "expenses")
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let expense = expenses[indexPath.row]
            let expensesRef = getExpensesDatabaseReference()
            expensesRef.child(expense.key).removeValue()
            expenses.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableCell(withIdentifier: "HeaderCell")
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

    private func sortExpenses() {
        expenses = expenses.sorted {
            $0.date > $1.date
        }
    }
}

extension ExpensesViewController {
    @IBAction func cancelToExpensesViewController(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func saveExpenseDetail(_ segue: UIStoryboardSegue) {
        if let expenseDetailsViewController = segue.source as? ExpenseDetailsViewController, let expense = expenseDetailsViewController.expense {
            let expensesRef = getExpensesDatabaseReference()
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                expense.key = expenses[selectedIndexPath.row].key
                expenses[selectedIndexPath.row] = expense
                let oldExpenseRef = expensesRef.child(expense.key)
                oldExpenseRef.setValue(expense.toAnyObject())
            } else {
                let newIndexPath = IndexPath(row: 0, section: 0)
                expenses.insert(expense, at: 0)
                let newExpenseRef = expensesRef.childByAutoId()
                expense.key = newExpenseRef.key
                newExpenseRef.setValue(expense.toAnyObject())
            }
            sortExpenses()
            tableView.reloadData()
        }
    }
}
