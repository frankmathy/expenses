//
//  ExpensesViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import UIKit
import CloudKit

class ExpensesViewController: UITableViewController, ExpenseObserver {
    
    var selectedExpense : Expense?
    
    var expenseModel = ExpenseByDateModel()
    
    var expenseDAO : ExpenseDAO?
    
    var expensesExported = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        expenseDAO = ExpenseDAO()
        expenseDAO!.addObserver(observer: self)
        expenseDAO?.observeExpenses()
    }
    
    func expensesChanged(expenses: [Expense]) {
        self.expenseModel.setExpenses(expenses: expenses)
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0: expenseModel.expensesCount(inSection: section - 1)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return expenseModel.sectionCount()+1
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let expenseCell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as? ExpenseCell else {
            fatalError("The dequeued cell is not an instance of ExpenseCell.")
        }
        let expense = expenseModel.expense(inSection: indexPath.section-1, row: indexPath.row)
        expenseCell.amountLabel.text = expense.amount.currencyInputFormatting()
        expenseCell.categoryLabel.text = expense.category.name
        expenseCell.commentLabel.text = expense.comment
        return expenseCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let expense = expenseModel.expense(inSection: indexPath.section-1, row: indexPath.row)
            expenseDAO!.removeExpense(expense: expense)
            expenseModel.removeExpense(inSection: indexPath.section-1, row: indexPath.row)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == 0) {
            guard var totalsCell = tableView.dequeueReusableCell(withIdentifier: "TotalsCell") as? TotalsViewCell else {
                fatalError("The queued cell is not an instance of TotalsCell")
            }
            totalsCell.amountLabel.text = expenseModel.grandTotal.currencyInputFormatting()
            return totalsCell
        } else {
            guard let headerCell: ExpenseGroupCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as? ExpenseGroupCell else {
                fatalError("The queued cell is not an instance of ExpenseGroupCell")
            }
            headerCell.dateLabel.text = expenseModel.sectionDate(inSection: section - 1).asLocaleWeekdayDateString
            headerCell.totalAmountLabel.text = expenseModel.totalAmount(inSection: section - 1).currencyInputFormatting()
            return headerCell
        }
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
            print("Adding a new expense.")
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
            let selectedExpense = expenseModel.expense(inSection: indexPath.section-1, row: indexPath.row)
            expsenseDetailsViewController.expense = Expense(byExpense: selectedExpense)

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
                // Update of expense
                let oldExpense = expenseModel.expense(inSection: selectedIndexPath.section-1, row: selectedIndexPath.row)
                expense.recordId = oldExpense.recordId
                expenseModel.removeExpense(inSection: selectedIndexPath.section-1, row: selectedIndexPath.row)
                expenseModel.addExpense(expense: expense)
                expenseDAO!.updateExpense(expense: expense)
            } else {
                // New expense
                expenseModel.addExpense(expense: expense)
                expenseDAO!.addExpense(expense: expense)
            }
            tableView.reloadData()
        }
    }
}
