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
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ExpensesViewController.totalsSwiped(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ExpensesViewController.totalsSwiped(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        // Remove blank table row lines
        self.tableView.tableFooterView = UIView()
        Model.sharedInstance.addObserver(observer: self)
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
        
        var font : UIFont
        if indexPath.row == 0 {
            cell.categoryName.text = Model.sharedInstance.dateIntervalSelectionText()
            font = UIFont.boldSystemFont(ofSize: cell.categoryName.font.pointSize)
            cell.amountLabel.text = ""
        } else if indexPath.row == self.tableView(tableView, numberOfRowsInSection: 0) - 1 {
            cell.categoryName.text = "Total"
            let totalAmount = Model.sharedInstance.expenseByCategoryModel?.grandTotal
            font = UIFont.boldSystemFont(ofSize: cell.categoryName.font.pointSize)
            cell.amountLabel.text = totalAmount?.currencyInputFormatting(currencySymbol: SystemConfig.sharedInstance.appCurrencySymbol)
        } else {
            let categoryName = Model.sharedInstance.expenseByCategoryModel?.sectionCategoryKey(inSection: indexPath.row - 1)
            let categoryAmount = Model.sharedInstance.expenseByCategoryModel?.totalAmount(forExpenseKey: categoryName!)
            font = UIFont.systemFont(ofSize: cell.categoryName.font.pointSize)
            cell.categoryName.text = categoryName
            cell.amountLabel.text = categoryAmount?.currencyInputFormatting(currencySymbol: SystemConfig.sharedInstance.appCurrencySymbol)
        }
        cell.categoryName.font = font
        cell.amountLabel.font = font
        return cell
    }
}
