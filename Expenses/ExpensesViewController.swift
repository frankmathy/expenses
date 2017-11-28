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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // os_log("Scrolled to %f", scrollView.contentOffset.y)
        let firstVisibleIndexPath = self.tableView.indexPathsForVisibleRows?.first
        print("First visible cell row=\(firstVisibleIndexPath?.row)")
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
