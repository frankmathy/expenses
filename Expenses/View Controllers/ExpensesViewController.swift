//
//  ExpensesViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import UIKit

class ExpensesViewController: UITableViewController, ModelDelegate {
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var addExpenseButton: UIBarButtonItem!
    
    private var selectedExpense : Expense?
    
    private let refreshTool = UIRefreshControl()
    
    var totalsCell : TotalsViewCell?

    var refreshPulled = false
    
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove blank table row lines
        self.tableView.tableFooterView = UIView()

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
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ExpensesViewController.totalsSwiped(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ExpensesViewController.totalsSwiped(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        // TODO: For push notifications - quick hack
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.expensesViewController = self
        
        navigationItem.leftBarButtonItem = editButtonItem
        editButtonItem.tintColor = .white
        Model.sharedInstance.addObserver(observer: self)
        Model.sharedInstance.loadAccounts()
        self.reloadExpenses(refreshPulled: false)
    }
    
    @objc func totalsSwiped(_ sender: UISwipeGestureRecognizer) -> Void {
        if sender.direction == .left {
            Model.sharedInstance.dateIntervalNext()
        } else if sender.direction == .right {
            Model.sharedInstance.dateIntervalPrevious()
        }
    }
    
    private func createInvisibleImage(cellFrame: CGRect) -> UIImageView {
        let overlayImage = UIImageView(frame: cellFrame)
        overlayImage.image = UIImage(named: "arrow_horiz_right_short")
        overlayImage.contentMode = .center
        overlayImage.isHidden=true
        return overlayImage
    }
    
    func modelUpdated() {
        DispatchQueue.main.async {
            if self.refreshPulled {
                self.refreshTool.endRefreshing()
                self.refreshPulled = false
            } else {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
            }
            self.tableView.reloadData()
        }
    }
    
    func reloadExpenses(refreshPulled: Bool) {
        self.refreshPulled = refreshPulled
        if !refreshPulled {
            DispatchQueue.main.async {
                self.indicator.startAnimating()
                self.indicator.backgroundColor = UIColor.white
            }
        }
        Model.sharedInstance.reloadExpenses()
        Model.sharedInstance.loadAccounts()
    }
    
    @objc private func refreshControlPulled(_ sender: Any) {
        reloadExpenses(refreshPulled: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0: Model.sharedInstance.expenseByDateModel!.expensesCount(inSection: section - 1)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Model.sharedInstance.expenseByDateModel!.sectionCount()+1
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let expenseCell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as? ExpenseCell else {
            fatalError("The dequeued cell is not an instance of ExpenseCell.")
        }
        let expense = Model.sharedInstance.expenseByDateModel!.expense(inSection: indexPath.section-1, row: indexPath.row)
        let currencySymbol = expense.account?.currencySymbol != nil ? expense.account?.currencySymbol : ""
        expenseCell.amountLabel.text = expense.amountAccountCcy?.currencyInputFormatting(currencySymbol: currencySymbol!)
        expenseCell.accountLabel.text = expense.account?.accountName
        expenseCell.categoryLabel.text = expense.category
        var commentText : String
        if expense.venueName != nil {
            commentText = expense.venueName!
        } else {
            commentText = expense.comment != nil ? expense.comment! : ""
        }
        if expense.currency != nil && expense.currency != SystemConfig.sharedInstance.appCurrencyCode && expense.currency?.count == 3 {
            if commentText.count > 0 {
                commentText = commentText + " - "
            }
            let symbol = ExchangeRateService.getSymbol(forCurrencyCode: expense.currency!)
            commentText = commentText + expense.amount.currencyInputFormatting(currencySymbol: symbol != nil ? symbol! : expense.currency!)
        }
        expenseCell.commentLabel.text = commentText
        return expenseCell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isEditing
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let expense = Model.sharedInstance.expenseByDateModel?.expense(inSection: indexPath.section-1, row: indexPath.row)
            Model.sharedInstance.removeExpense(expense: expense!)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == 0) {
            totalsCell = tableView.dequeueReusableCell(withIdentifier: "TotalsCell") as? TotalsViewCell
            if totalsCell == nil {
                fatalError("The queued cell is not an instance of TotalsCell")
            }
            totalsCell?.amountLabel.text = Model.sharedInstance.expenseByDateModel!.grandTotal.currencyInputFormatting(currencySymbol: SystemConfig.sharedInstance.appCurrencySymbol)
            totalsCell?.dateRangeButton.layer.cornerRadius = 10
            totalsCell?.dateRangeButton.clipsToBounds = true
            updateDateIntervalFields()
            return totalsCell
        } else {
            guard let headerCell: ExpenseGroupCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as? ExpenseGroupCell else {
                fatalError("The queued cell is not an instance of ExpenseGroupCell")
            }
            headerCell.dateLabel.text = Model.sharedInstance.expenseByDateModel!.sectionCategoryKey(inSection: section - 1)!.asLocaleWeekdayDateString
            headerCell.totalAmountLabel.text = Model.sharedInstance.expenseByDateModel?.totalAmount(inSection: section - 1).currencyInputFormatting(currencySymbol: SystemConfig.sharedInstance.appCurrencySymbol)
            return headerCell
        }
    }
    
    func updateDateIntervalFields() {
        let showAllData = Model.sharedInstance.dateIntervalSelection.dateIntervalType == DateIntervalType.All
        totalsCell!.dateLeftButton.isUserInteractionEnabled = !showAllData
        totalsCell!.dateRightButton.isUserInteractionEnabled = !showAllData
        if totalsCell != nil {
            totalsCell!.dateRangeButton.setTitle(Model.sharedInstance.dateIntervalSelectionText(), for: .normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
        case "AddExpense":
            guard let expenseDetailsViewController = segue.destination as? ExpenseDetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            print("Adding a new expense.")
            expenseDetailsViewController.newExpense = true
        case "EditExpense":
            guard let expenseDetailsViewController = segue.destination as? ExpenseDetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedExpenseCell = sender as? ExpenseCell else {
                fatalError("Unexpected sender: \(sender!)")
            }
            guard let indexPath = tableView.indexPath(for: selectedExpenseCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedExpense = Model.sharedInstance.expenseByDateModel?.expense(inSection: indexPath.section-1, row: indexPath.row)
            expenseDetailsViewController.expense = selectedExpense!
            expenseDetailsViewController.newExpense = false
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier!)")
        }
    }
    
    func cloudAccessError(message: String, error: NSError) {
        DispatchQueue.main.async {
            let body: String
            if error.code == 1 {
                body = NSLocalizedString("LogIntoICloud", comment: "")
            } else {
                body = error.localizedDescription
            }
            let alertController = UIAlertController(title: message, message: body, preferredStyle: .actionSheet)
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func dateIntervalChanged() {
        DispatchQueue.main.async {
            self.updateDateIntervalFields()
            self.reloadExpenses(refreshPulled: false)
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        let csv = Model.sharedInstance.CSV()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd HHmmss"
        let fileName = "Expenses " + formatter.string(from: Date()) + ".txt"
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        do {
            try csv.write(to: path, atomically: true, encoding: String.Encoding.utf8)
            let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
            vc.popoverPresentationController?.barButtonItem = sender as! UIBarButtonItem
            vc.excludedActivityTypes = [
                UIActivityType.assignToContact,
                UIActivityType.saveToCameraRoll,
                UIActivityType.postToFlickr,
                UIActivityType.postToVimeo,
                UIActivityType.postToTencentWeibo,
                UIActivityType.postToTwitter,
                UIActivityType.postToFacebook,
                UIActivityType.openInIBooks
            ]
            present(vc, animated: true, completion: nil)
        } catch {
        }
    }
    
}

extension ExpensesViewController {
    @IBAction func cancelToExpensesViewController(_ segue: UIStoryboardSegue) {
        CoreDataUtil.sharedInstance.rollbackChanges()
        self.reloadExpenses(refreshPulled: false)
    }
    
    @IBAction func saveExpenseDetail(_ segue: UIStoryboardSegue) {
        if let expenseDetailsViewController = segue.source as? ExpenseDetailsViewController, let expense = expenseDetailsViewController.expense {
            let config = SystemConfig.sharedInstance
            config.lastCategory = expense.category
            config.lastProject = expense.project
            config.lastAccount = expense.account?.accountName
            let newExpense = expenseDetailsViewController.newExpense!
            Model.sharedInstance.updateExpense(expense: expense, isNewExpense: newExpense)
            Model.sharedInstance.reloadExpenses()
            Model.sharedInstance.modelUpdated()
        }
    }
}
