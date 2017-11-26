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
            dateLabel.text = expense.date.asLocaleDateTimeString
            amountLabel.text = expense.amount.asLocaleCurrency
            categoryLabel.text = expense.category.name
            let categoryBalance = expense.amount*2.12
            categoryBalanceLabel.text = categoryBalance.asLocaleCurrency
            accountLabel.text = expense.account.name
            let accountBalance = expense.amount*3.47
            accountBalanceLabel.text = accountBalance.asLocaleCurrency
            
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


