//
//  ExpenseDetailsViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 28.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import UIKit

class ExpenseDetailsViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    
    var datePicker : UIDatePicker!

    var expense: Expense? {
        didSet {
            amountTextField.text = expense?.amount.asLocaleCurrency
            expenseDate = expense?.date
        }
    }
    
    var expenseDate: Date? {
        didSet {
            dateField.text = expenseDate?.asLocaleDateTimeString
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
    
    //MARK:- textFiled Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === dateField {
            self.pickUpDate(dateField)
        }
    }
    
    //MARK:- Function of datePicker
    func pickUpDate(_ textField : UITextField){
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        if let date = expenseDate {
            self.datePicker.date = date
        }
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePickerMode.dateAndTime
        self.datePicker.maximumDate = Date()
        textField.inputView = self.datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ExpenseDetailsViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(ExpenseDetailsViewController.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    // MARK:- Button Done and Cancel
    @objc func doneClick() {
        expenseDate = datePicker.date
        dateField.resignFirstResponder()
    }
    
    @objc func cancelClick() {
        dateField.resignFirstResponder()
    }
}

extension ExpenseDetailsViewController {
    @IBAction func unwindWithSelectedGame(segue: UIStoryboardSegue) {
        /*        if let gamePickerViewController = segue.source as? GamePickerViewController,
         let selectedGame = gamePickerViewController.selectedGame {
         game = selectedGame
         } */
    }
}
