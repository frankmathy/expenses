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
        print("Date button pressed")
        let alert = UIAlertController(title: "Expenses", message: "Set Date Range", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Action 1", style: .default, handler: { (action) -> Void in
            print("ACTION 1 selected!")
        })
        
        let action2 = UIAlertAction(title: "Action 2", style: .default, handler: { (action) -> Void in
            print("ACTION 2 selected!")
        })
        
        let action3 = UIAlertAction(title: "Action 3", style: .default, handler: { (action) -> Void in
            print("ACTION 3 selected!")
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(cancel)
        parentViewController?.present(alert, animated: true, completion: nil)
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
