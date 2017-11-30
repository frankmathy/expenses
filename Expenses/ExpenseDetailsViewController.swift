//
//  ExpenseDetailsViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 28.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import UIKit

class ExpenseDetailsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var projectField: UITextField!
    
    var datePicker : UIDatePicker!
    var pickerView : UIPickerView!
    
    var editedTextField: UITextField?
    
    var expense: Expense? {
        didSet {
            amountTextField.text = expense?.amount.asLocaleCurrency
            expenseDate = expense?.date
            category = expense?.category
            account = expense?.account
            project = expense?.project
        }
    }
    
    var expenseDate: Date? {
        didSet {
            dateField.text = expenseDate?.asLocaleDateTimeString
        }
    }
    
    var category: Category? {
        didSet {
            categoryField.text = category?.name
        }
    }
    
    var account: Account? {
        didSet {
            accountField.text = account?.name
        }
    }
    
    var project: Project? {
        didSet {
            projectField.text = project?.name
        }
    }
    
    let categories = SampleData.getCategories()
    
    let accounts = SampleData.getAccounts()
    
    let projects = SampleData.getProjects()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTextField.addTarget(self, action: #selector(amountTextFieldDidChange), for: .editingChanged)
        dateField.addTarget(self, action: #selector(dateFieldEditingDidBegin), for: .editingDidBegin)
        categoryField.addTarget(self, action: #selector(pickerEditingDidBegin), for: .editingDidBegin)
        accountField.addTarget(self, action: #selector(pickerEditingDidBegin), for: .editingDidBegin)
        projectField.addTarget(self, action: #selector(pickerEditingDidBegin), for: .editingDidBegin)
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
    
    @objc func dateFieldEditingDidBegin(_ textField : UITextField) {
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
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ExpenseDetailsViewController.dateDoneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(ExpenseDetailsViewController.dateCancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    @objc func dateDoneClick() {
        expenseDate = datePicker.date
        dateField.resignFirstResponder()
    }
    
    @objc func dateCancelClick() {
        dateField.resignFirstResponder()
    }
    
    @objc func pickerEditingDidBegin(_ textField : UITextField) {
        self.editedTextField = textField
        
        self.pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.pickerView.backgroundColor = UIColor.white
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        textField.inputView = self.pickerView
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ExpenseDetailsViewController.pickerDoneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(ExpenseDetailsViewController.pickerCancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    @objc func pickerDoneClick() {
        let row = self.pickerView.selectedRow(inComponent: 0)
        if self.editedTextField === self.categoryField {
            self.categoryField.text = categories[row].name
        } else if self.editedTextField === self.accountField {
            self.accountField.text = accounts[row].name
        } else if self.editedTextField === self.projectField {
            self.projectField.text = projects[row].name
        }
        self.editedTextField!.resignFirstResponder()
    }
    
    @objc func pickerCancelClick() {
        self.editedTextField!.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if editedTextField === categoryField {
            return categories[row].name
        } else if editedTextField === accountField {
            return accounts[row].name
        } else if editedTextField === projectField {
            return projects[row].name
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if editedTextField === categoryField {
            return categories.count
        } else if editedTextField === accountField {
            return accounts.count
        } else if editedTextField === projectField {
            return projects.count
        } else {
            return 0
        }
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

