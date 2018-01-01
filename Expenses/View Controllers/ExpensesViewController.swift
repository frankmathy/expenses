//
//  ExpensesViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import UIKit
import CloudKit

class ExpensesViewController: UITableViewController, ModelDelegate {
    private var selectedExpense : Expense?
    
    private let refreshTool = UIRefreshControl()
    
    var totalsCell : TotalsViewCell?

    var expensesExported = false
    
    var refreshPulled = false
    
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        
        refreshTool.addTarget(self, action: #selector(refreshControlPulled(_:)), for: .valueChanged)
        refreshTool.attributedTitle = NSAttributedString(string: NSLocalizedString("Reloading Expenses", comment: ""))
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshTool
        } else {
            tableView.addSubview(refreshTool)
        }
        
        // TODO: For push notifications - quick hack
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.expensesViewController = self
        
        navigationItem.leftBarButtonItem = editButtonItem
        Model.sharedInstance.addObserver(observer: self)
        reloadExpenses(refreshPulled: false)
    }
    
    func modelUpdated(expenses: [Expense]) {
        if refreshPulled {
            refreshTool.endRefreshing()
            refreshPulled = false
        } else {
            DispatchQueue.main.async {
            self.indicator.stopAnimating()
            self.indicator.hidesWhenStopped = true
                // ViewControllerUtils().hideActivityIndicator()
            }
        }
        Model.sharedInstance.expenseModel!.setExpenses(expenses: expenses)
        self.tableView.reloadData()
    }
    
    func reloadExpenses(refreshPulled: Bool) {
        self.refreshPulled = refreshPulled
        if !refreshPulled {
            DispatchQueue.main.async {
                self.indicator.startAnimating()
                self.indicator.backgroundColor = UIColor.white
                // ViewControllerUtils().showActivityIndicator(uiView: self.view)
            }
        }
        Model.sharedInstance.reloadExpenses()
    }
    
    @objc private func refreshControlPulled(_ sender: Any) {
        reloadExpenses(refreshPulled: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0: Model.sharedInstance.expenseModel!.expensesCount(inSection: section - 1)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Model.sharedInstance.expenseModel!.sectionCount()+1
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let expenseCell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as? ExpenseCell else {
            fatalError("The dequeued cell is not an instance of ExpenseCell.")
        }
        let expense = Model.sharedInstance.expenseModel!.expense(inSection: indexPath.section-1, row: indexPath.row)
        expenseCell.amountLabel.text = expense.amount.currencyInputFormatting()
        expenseCell.accountLabel.text = expense.account.name
        expenseCell.categoryLabel.text = expense.category.name
        expenseCell.commentLabel.text = expense.comment
        return expenseCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let expense = Model.sharedInstance.expenseModel?.expense(inSection: indexPath.section-1, row: indexPath.row)
            Model.sharedInstance.removeExpense(expense: expense!)
            Model.sharedInstance.expenseModel?.removeExpense(inSection: indexPath.section-1, row: indexPath.row)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == 0) {
            totalsCell = tableView.dequeueReusableCell(withIdentifier: "TotalsCell") as? TotalsViewCell
            if totalsCell == nil {
                fatalError("The queued cell is not an instance of TotalsCell")
            }
            totalsCell?.amountLabel.text = Model.sharedInstance.expenseModel!.grandTotal.currencyInputFormatting()
            updateDateIntervalFields()
            return totalsCell
        } else {
            guard let headerCell: ExpenseGroupCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as? ExpenseGroupCell else {
                fatalError("The queued cell is not an instance of ExpenseGroupCell")
            }
            headerCell.dateLabel.text = Model.sharedInstance.expenseModel!.sectionCategoryKey(inSection: section - 1).asLocaleWeekdayDateString
            headerCell.totalAmountLabel.text = Model.sharedInstance.expenseModel?.totalAmount(inSection: section - 1).currencyInputFormatting()
            return headerCell
        }
    }
    
    func updateDateIntervalFields() {
        let showAllData = Model.sharedInstance.dateIntervalSelection.dateIntervalType == DateIntervalType.All
        totalsCell!.dateLeftButton.isUserInteractionEnabled = !showAllData
        totalsCell!.dateRightButton.isUserInteractionEnabled = !showAllData
        if totalsCell != nil {
            switch(Model.sharedInstance.dateIntervalSelection.dateIntervalType) {
            case .All:
                    totalsCell!.dateRangeButton.setTitle(NSLocalizedString("All", comment: ""), for: .normal)
            case .Month:
                    let dateFormat = DateFormatter()
                    dateFormat.dateFormat = "MMMM yyyy"
                    totalsCell!.dateRangeButton.setTitle(dateFormat.string(from: Model.sharedInstance.dateIntervalSelection.startDate!), for: .normal)
            case .Year:
                    let dateFormat = DateFormatter()
                    dateFormat.dateFormat = "yyyy"
                    totalsCell!.dateRangeButton.setTitle(dateFormat.string(from: Model.sharedInstance.dateIntervalSelection.startDate!), for: .normal)
            case .Week:
                    let dateFormat = DateFormatter()
                    dateFormat.dateFormat = "dd.MM."
                    let startDateString = dateFormat.string(from: Model.sharedInstance.dateIntervalSelection.startDate!)
                    dateFormat.dateFormat = "dd.MM.yyyy"
                    let endDateString = dateFormat.string(from: Model.sharedInstance.dateIntervalSelection.endDate!)
                    totalsCell!.dateRangeButton.setTitle(startDateString + "-" + endDateString, for: .normal)
            }
        }
    }
    
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
            let selectedExpense = Model.sharedInstance.expenseModel?.expense(inSection: indexPath.section-1, row: indexPath.row)
            expsenseDetailsViewController.expense = Expense(asCopy: selectedExpense!)

        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier)")
        }
    }
    
    func cloudAccessError(message: String, error: NSError) {
        let body: String
        if error.code == 1 {
            body = NSLocalizedString("LogIntoICloud", comment: "")
        } else {
            body = error.localizedDescription
        }
        let alertController = UIAlertController(title: message, message: body, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func dateIntervalChanged() {
        updateDateIntervalFields()
        reloadExpenses(refreshPulled: false)
    }
}

extension ExpensesViewController {
    @IBAction func cancelToExpensesViewController(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func saveExpenseDetail(_ segue: UIStoryboardSegue) {
        if let expenseDetailsViewController = segue.source as? ExpenseDetailsViewController, let expense = expenseDetailsViewController.expense {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update of expense
                Model.sharedInstance.expenseModel?.removeExpense(inSection: selectedIndexPath.section-1, row: selectedIndexPath.row)
                Model.sharedInstance.expenseModel?.addExpense(expense: expense)
                Model.sharedInstance.updateExpense(expense: expense)
            } else {
                // New expense
                Model.sharedInstance.expenseModel?.addExpense(expense: expense)
                Model.sharedInstance.addExpense(expense: expense)
            }
            tableView.reloadData()
        }
    }
}
