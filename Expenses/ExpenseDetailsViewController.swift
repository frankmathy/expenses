//
//  ExpenseDetailsViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 28.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import UIKit

class ExpenseDetailsViewController: UITableViewController {
    @IBOutlet weak var amountTextField: UITextField!

    var expense: Expense? {
        didSet {
            amountTextField.text = expense?.amount.asLocaleCurrency
        }
    }
    

    /*
    var game: String = "Chess" {
        didSet {
            detailLabel.text = game
        }
    }
 */
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTextField.addTarget(self, action: #selector(amountTextFieldDidChange), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        amountTextField.becomeFirstResponder()
    }
    

    
    @objc func amountTextFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
/*        if segue.identifier == "SaveExpenseDetail",
            let playerName = nameTextField.text {
            player = Player(name: playerName, game: game, rating: 1)
        }
        if segue.identifier == "PickGame",
            let gamePickerController = segue.destination as? GamePickerViewController {
            gamePickerController.selectedGame = game
        }*/
    }
    
}

extension ExpenseDetailsViewController {
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            amountTextField.becomeFirstResponder();
        }
    }

    @IBAction func unwindWithSelectedGame(segue: UIStoryboardSegue) {
/*        if let gamePickerViewController = segue.source as? GamePickerViewController,
            let selectedGame = gamePickerViewController.selectedGame {
            game = selectedGame
        } */
    }
}

extension ExpenseDetailsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
/*        if indexPath.section == 0 {
            nameTextField.becomeFirstResponder();
        }*/
    }
}




