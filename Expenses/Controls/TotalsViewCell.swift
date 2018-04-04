//
//  TotalsViewCell.swift
//  Expenses
//
//  Created by Frank Mathy on 24.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import UIKit

class TotalsViewCell: UITableViewCell {
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLeftButton: UIButton!
    @IBOutlet weak var dateRangeButton: UIButton!
    @IBOutlet weak var dateRightButton: UIButton!
    
    @IBAction func dateRangeButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: NSLocalizedString("Expenses", comment: ""), message: NSLocalizedString("Set Date Interval", comment: ""), preferredStyle: .alert)
        let actionToday = UIAlertAction(title: NSLocalizedString("Today", comment: ""), style: .default, handler: { (action) -> Void in
            Model.sharedInstance.setDateToday()
        })
        let actionWeek = UIAlertAction(title: NSLocalizedString("Week", comment: ""), style: .default, handler: { (action) -> Void in
            Model.sharedInstance.setDateIntervalType(dateIntervalType: DateIntervalType.Week)
        })
        let actionMonth = UIAlertAction(title: NSLocalizedString("Month", comment: ""), style: .default, handler: { (action) -> Void in
            Model.sharedInstance.setDateIntervalType(dateIntervalType: DateIntervalType.Month)
        })
        let actionYear = UIAlertAction(title: NSLocalizedString("Year", comment: ""), style: .default, handler: { (action) -> Void in
            Model.sharedInstance.setDateIntervalType(dateIntervalType: DateIntervalType.Year)
        })
        let actionAll = UIAlertAction(title: NSLocalizedString("All", comment: ""), style: .default, handler: { (action) -> Void in
            Model.sharedInstance.setDateIntervalType(dateIntervalType: DateIntervalType.All)
        })

        // Cancel button
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: { (action) -> Void in })
        alert.addAction(actionToday)
        alert.addAction(actionWeek)
        alert.addAction(actionMonth)
        alert.addAction(actionYear)
        alert.addAction(actionAll)
        alert.addAction(cancel)
        parentViewController?.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onPreviousPressed(_ sender: UIButton) {
        Model.sharedInstance.dateIntervalPrevious()
    }
    
    @IBAction func onNextPressed(_ sender: UIButton) {
        Model.sharedInstance.dateIntervalNext()
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController!
            }
        }
        return nil
    }
}
