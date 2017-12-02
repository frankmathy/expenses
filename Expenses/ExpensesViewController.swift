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
    
    var expenses = SampleData.getExpenses().sorted {
        $0.date > $1.date
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
        if segue.identifier == "AddExpense" {
            let navigationController = segue.destination as! UINavigationController
            let expenseDetailsViewController = navigationController.topViewController as! ExpenseDetailsViewController
            let newExpense = Expense(date: Date(), category: SampleData.getCategories()[0], account: SampleData.getAccounts()[0], project: SampleData.getProjects()[0], amount: 0.0, comment: "Test")
            expenseDetailsViewController.initialExpense = newExpense
        } else if segue.identifier == "EditExpense" {
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
        
        expenses.insert(expense, at: 0)
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
}
