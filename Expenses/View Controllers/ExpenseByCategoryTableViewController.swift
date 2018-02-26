//
//  ExpenseByCategoryTableViewController.swift
//  
//
//  Created by Frank Mathy on 01.01.18.
//

import UIKit

class ExpenseByCategoryTableViewController: UITableViewController, ModelDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Model.sharedInstance.addObserver(observer: self)
    }
    
    func modelUpdated() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func dateIntervalChanged() {
    }
    
    func cloudAccessError(message: String, error: NSError) {
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (Model.sharedInstance.expenseByCategoryModel?.sectionCount())! + 2
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseByCategoryCell", for: indexPath) as? ExpenseByCategoryCell else {
            fatalError("The dequeued cell is not an instance of ExpenseByCategoryTableViewCell.")
        }
        
        if indexPath.row == 0 {
            cell.categoryName.text = Model.sharedInstance.dateIntervalSelectionText()
            cell.amountLabel.text = ""
        } else if indexPath.row == self.tableView(tableView, numberOfRowsInSection: 0) - 1 {
            cell.categoryName.text = "Total"
            let totalAmount = Model.sharedInstance.expenseByCategoryModel?.grandTotal
            cell.amountLabel.text = totalAmount?.currencyInputFormatting()
        } else {
            let categoryName = Model.sharedInstance.expenseByCategoryModel?.sectionCategoryKey(inSection: indexPath.row - 1)
            let categoryAmount = Model.sharedInstance.expenseByCategoryModel?.totalAmount(forExpenseKey: categoryName!)
            cell.categoryName.text = categoryName
            cell.amountLabel.text = categoryAmount?.currencyInputFormatting()
        }
        return cell
    }
}
