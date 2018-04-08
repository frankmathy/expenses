//
//  ExpenseByCategoryTableViewController.swift
//  
//
//  Created by Frank Mathy on 01.01.18.
//

import UIKit
import Instructions

class ExpenseByCategoryTableViewController: UITableViewController, ModelDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate {

    let coachMarksController = CoachMarksController()
    
    let helpTextIds = [
        "Help.ExpenseReport.Main" ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.coachMarksController.dataSource = self
        // Remove blank table row lines
        self.tableView.tableFooterView = UIView()
        Model.sharedInstance.addObserver(observer: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !SystemConfig.sharedInstance.expenseReportScreenHelpWasDisplayed {
            SystemConfig.sharedInstance.expenseReportScreenHelpWasDisplayed = true
            self.coachMarksController.start(on: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.coachMarksController.stop(immediately: true)
    }
    
    @IBAction func helpButtonPressed(_ sender: UIBarButtonItem) {
        self.coachMarksController.start(on: self)
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return helpTextIds.count
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch index {
        case 0:
            var cellFrame: CGRect = CGRect()
            let app = UIApplication.shared
            cellFrame.origin.y = self.navigationController!.navigationBar.frame.size.height + app.statusBarFrame.size.height
            cellFrame.origin.x = tableView.frame.origin.x
            cellFrame.size = CGSize(width: tableView.frame.size.width, height: self.tableView.rowHeight)
            let overlayImage = createInvisibleImage(cellFrame: cellFrame)
            self.navigationController?.view.addSubview(overlayImage)
            return coachMarksController.helper.makeCoachMark(for: overlayImage)
        default:
            return coachMarksController.helper.makeCoachMark(for: self.view)
        }
    }
    
    private func createInvisibleImage(cellFrame: CGRect) -> UIImageView {
        let overlayImage = UIImageView(frame: cellFrame)
        overlayImage.image = UIImage(named: "arrow_horiz_right_short")
        overlayImage.contentMode = .center
        overlayImage.isHidden=true
        return overlayImage
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        coachViews.bodyView.hintLabel.text = NSLocalizedString(helpTextIds[index], comment: "")
        coachViews.bodyView.nextLabel.text = NSLocalizedString(index < helpTextIds.count-1  ? "Next" : "OK", comment: "")
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
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
            cell.categoryName.font = UIFont.boldSystemFont(ofSize: cell.categoryName.font.pointSize)
            cell.amountLabel.text = ""
        } else if indexPath.row == self.tableView(tableView, numberOfRowsInSection: 0) - 1 {
            cell.categoryName.text = "Total"
            cell.categoryName.font = UIFont.boldSystemFont(ofSize: cell.categoryName.font.pointSize)
            let totalAmount = Model.sharedInstance.expenseByCategoryModel?.grandTotal
            cell.amountLabel.text = totalAmount?.currencyInputFormatting()
            cell.amountLabel.font = UIFont.boldSystemFont(ofSize: cell.amountLabel.font.pointSize)
        } else {
            let categoryName = Model.sharedInstance.expenseByCategoryModel?.sectionCategoryKey(inSection: indexPath.row - 1)
            let categoryAmount = Model.sharedInstance.expenseByCategoryModel?.totalAmount(forExpenseKey: categoryName!)
            cell.categoryName.text = categoryName
            cell.amountLabel.text = categoryAmount?.currencyInputFormatting()
        }
        return cell
    }
}
