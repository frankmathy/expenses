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
    
    private var expenseModel = ExpenseByDateModel()
    
    var model = Model.sharedInstance

    private let refreshTool = UIRefreshControl()
    
    var totalsCell : TotalsViewCell?

    var expensesExported = false
    
    var refreshPulled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        model.addObserver(observer: self)
        reloadExpenses(refreshPulled: false)
    }
    
    func modelUpdated(expenses: [Expense]) {
        if refreshPulled {
            refreshTool.endRefreshing()
            refreshPulled = false
        } else {
            // ViewControllerUtils().hideActivityIndicator()
        }
        self.expenseModel.setExpenses(expenses: expenses)
        self.tableView.reloadData()
    }
    
    func reloadExpenses(refreshPulled: Bool) {
        self.refreshPulled = refreshPulled
        if !refreshPulled {
            // ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        model.reloadExpenses()
    }
    
    @objc private func refreshControlPulled(_ sender: Any) {
        reloadExpenses(refreshPulled: true)
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
        expenseCell.accountLabel.text = expense.account.name
        expenseCell.categoryLabel.text = expense.category.name
        expenseCell.commentLabel.text = expense.comment
        return expenseCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let expense = expenseModel.expense(inSection: indexPath.section-1, row: indexPath.row)
            model.removeExpense(expense: expense)
            expenseModel.removeExpense(inSection: indexPath.section-1, row: indexPath.row)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == 0) {
            totalsCell = tableView.dequeueReusableCell(withIdentifier: "TotalsCell") as? TotalsViewCell
            if totalsCell == nil {
                fatalError("The queued cell is not an instance of TotalsCell")
            }
            totalsCell?.amountLabel.text = expenseModel.grandTotal.currencyInputFormatting()
            updateDateIntervalFields()
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
    
    func updateDateIntervalFields() {
        let showAllData = model.dateIntervalSelection.dateIntervalType == DateIntervalType.All
        totalsCell!.dateLeftButton.isUserInteractionEnabled = !showAllData
        totalsCell!.dateRightButton.isUserInteractionEnabled = !showAllData
        if totalsCell != nil {
            switch(model.dateIntervalSelection.dateIntervalType) {
            case .All:
                    totalsCell!.dateRangeButton.setTitle(NSLocalizedString("All", comment: ""), for: .normal)
            case .Month:
                    let dateFormat = DateFormatter()
                    dateFormat.dateFormat = "MMMM yyyy"
                    totalsCell!.dateRangeButton.setTitle(dateFormat.string(from: model.dateIntervalSelection.startDate!), for: .normal)
            case .Year:
                    let dateFormat = DateFormatter()
                    dateFormat.dateFormat = "yyyy"
                    totalsCell!.dateRangeButton.setTitle(dateFormat.string(from: model.dateIntervalSelection.startDate!), for: .normal)
            case .Week:
                    let dateFormat = DateFormatter()
                    dateFormat.dateFormat = "dd.MM."
                    let startDateString = dateFormat.string(from: model.dateIntervalSelection.startDate!)
                    dateFormat.dateFormat = "dd.MM.yyyy"
                    let endDateString = dateFormat.string(from: model.dateIntervalSelection.endDate!)
                    totalsCell!.dateRangeButton.setTitle(startDateString + "-" + endDateString, for: .normal)
            }
        }
    }
    
    @IBAction func importData(_ sender: Any) {
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
                    let expense = Expense(date: date!, category: NamedItem(asCategory: category), account: Account(byName: account), project: NamedItem(asProject: project), amount: amount, comment: comment)
                    model.addExpense(expense: expense)
                }
            }
            print("Imported \((newExpenses.count)) expenses")
        } catch {
            print("File Read Error for file \(path)")
            return
        }
    }
    
    @IBAction func exportData(_ sender: Any) {
        let userDocumentsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = userDocumentsFolder.appending("/Expenses.csv")
        let fileURL = URL(fileURLWithPath: path)
        var csv = ""
        let dateFormat = ISO8601DateFormatter()
        for section in 0..<(expenseModel.sectionCount()) {
            for row in 0..<(expenseModel.expensesCount(inSection: section)) {
                let expense = expenseModel.expense(inSection: section, row: row)
                let dateString = dateFormat.string(from: expense.date)
                let amountString = String(expense.amount)
                csv += "\(dateString)\t\(amountString)\t\(expense.account.name)\t\(expense.category.name)\t\(expense.project.name)\t\(expense.comment)\t \n"
            }
        }
        do {
            try csv.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("error")
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
            let selectedExpense = expenseModel.expense(inSection: indexPath.section-1, row: indexPath.row)
            expsenseDetailsViewController.expense = Expense(asCopy: selectedExpense)

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
                expenseModel.removeExpense(inSection: selectedIndexPath.section-1, row: selectedIndexPath.row)
                expenseModel.addExpense(expense: expense)
                model.updateExpense(expense: expense)
            } else {
                // New expense
                expenseModel.addExpense(expense: expense)
                model.addExpense(expense: expense)
            }
            tableView.reloadData()
        }
    }
}
