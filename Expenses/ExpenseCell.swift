//
//  ExpenseCell.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import UIKit

class ExpenseCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryBalanceLabel: UILabel!
    
    var expense: Expense? {
        didSet {
            guard let expense = expense else { return }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale.current
            dateLabel.text = dateFormatter.string(from: expense.date)
            
            let amountFormatter = NumberFormatter()
            amountFormatter.locale = Locale.current
            amountFormatter.numberStyle = .currency
            
            //amountLabel.text = amountFormatter.string(from: expense.amount as! NSDecimalNumber)
            
            accountLabel.text = expense.account.name
            //accountBalanceLabel.text = amountFormatter.string(from: expense.amount*3)
            
            categoryLabel.text = expense.category.name
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
