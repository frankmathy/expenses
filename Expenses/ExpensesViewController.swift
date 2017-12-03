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
        if segue.destination is UINavigationController {
            let navigationController = segue.destination as! UINavigationController
            if navigationController.topViewController is ExpenseDetailsViewController {
                let expenseDetailsViewController = navigationController.topViewController as! ExpenseDetailsViewController
                if segue.identifier == "AddExpense" {
                    let newExpense = Expense(date: Date(), category: SampleData.getCategories()[0], account: SampleData.getAccounts()[0], project: SampleData.getProjects()[0], amount: 0.0, comment: "Test")
                    expenseDetailsViewController.expense = newExpense
                    expenseDetailsViewController.expenseIndexPath = nil
                } else if segue.identifier == "EditExpense" {
                    if sender is IndexPath {
                        expenseDetailsViewController.expenseIndexPath = (sender as! IndexPath)
                        expenseDetailsViewController.expense = Expense(byExpense: self.expenses[(expenseDetailsViewController.expenseIndexPath?.row)!])
                    }
                }
            }
        }
    }
}

extension ExpensesViewController {
    @IBAction func cancelToExpensesViewController(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func saveExpenseDetail(_ segue: UIStoryboardSegue) {
        guard let expenseDetailsViewController = segue.source as? ExpenseDetailsViewController,
            let expense = expenseDetailsViewController.expense else {
                return
        }
        
        if(expenseDetailsViewController.expenseIndexPath != nil) {
            self.expenses[(expenseDetailsViewController.expenseIndexPath?.row)!] = expenseDetailsViewController.expense!
            tableView.reloadRows(at: [expenseDetailsViewController.expenseIndexPath!], with: UITableViewRowAnimation.automatic)
        } else {
            expenses.insert(expense, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
}
