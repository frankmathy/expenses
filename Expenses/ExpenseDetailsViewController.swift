//
//  ExpenseDetailsViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 28.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import UIKit

class ExpenseDetailsViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var categoryField: UILabel!
    @IBOutlet weak var accountField: UILabel!
    @IBOutlet weak var projectField: UILabel!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var datePicker : UIDatePicker!
    var pickerView : UIPickerView!
    
    var editedTextField: UITextField?
    
    var expense: Expense?
    
    let categories = SampleData.getCategories()
    
    let accounts = SampleData.getAccounts()
    
    let projects = SampleData.getProjects()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTextField.addTarget(self, action: #selector(amountTextFieldDidChange), for: .editingChanged)
/*        dateField.addTarget(self, action: #selector(dateFieldEditingDidBegin), for: .editingDidBegin)
        categoryField.addTarget(self, action: #selector(pickerEditingDidBegin), for: .editingDidBegin)
        accountField.addTarget(self, action: #selector(pickerEditingDidBegin), for: .editingDidBegin)
        projectField.addTarget(self, action: #selector(pickerEditingDidBegin), for: .editingDidBegin)*/
        commentField.addTarget(self, action: #selector(commentTextFieldDidChange), for: .editingChanged)

        if expense != nil {
            navigationItem.title = NSLocalizedString("Edit Expense", comment: "")
        } else {
            navigationItem.title = NSLocalizedString("Add Expense", comment: "")
            expense = Expense(date: Date(), category: SampleData.categoryGroceries!, account: SampleData.accountHousehold!, project: SampleData.projectNone!, amount: 0.0, comment: "")
        }
        amountTextField.text = expense!.amount.currencyInputFormatting()
        dateField.text = expense!.date.asLocaleDateTimeString
        categoryField.text = expense!.category.name
        accountField.text = expense!.account.name
        projectField.text = expense!.project.name
        commentField.text = expense!.comment

        updateSaveButtonState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        amountTextField.becomeFirstResponder()
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddExpenseMode = presentingViewController is UINavigationController
        if isPresentingInAddExpenseMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
    
    
    @objc func amountTextFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
            expense?.amount = amountString.parseCurrencyValue()
            updateSaveButtonState()
        }
    }
    
    @objc func commentTextFieldDidChange(_ textField: UITextField) {
        if let comment = textField.text {
            expense?.comment = comment
            updateSaveButtonState()
        }
    }
    
    @objc func dateFieldEditingDidBegin(_ textField : UITextField) {
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        if let date = expense?.date {
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
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .plain, target: self, action: #selector(ExpenseDetailsViewController.dateDoneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(ExpenseDetailsViewController.dateCancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    @objc func dateDoneClick() {
        expense?.date = datePicker.date
        dateField.text = expense?.date.asLocaleDateTimeString
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
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .plain, target: self, action: #selector(ExpenseDetailsViewController.pickerDoneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(ExpenseDetailsViewController.pickerCancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    @objc func pickerDoneClick() {
        let row = self.pickerView.selectedRow(inComponent: 0)
        if self.editedTextField === self.categoryField {
            expense?.category = categories[row]
            self.categoryField.text = expense?.category.name
            updateSaveButtonState()
        } else if self.editedTextField === self.accountField {
            expense?.account = accounts[row]
            self.accountField.text = expense?.account.name
            updateSaveButtonState()
        } else if self.editedTextField === self.projectField {
            expense?.project = projects[row]
            self.projectField.text = expense?.project.name
            updateSaveButtonState()
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
    
    private func updateSaveButtonState() {
        saveButton.isEnabled = expense!.amount != 0.0 && expense?.category != nil && expense?.account != nil && expense?.project != nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
        case "PickCategory":
            guard let categoryTableViewController = segue.destination as? CategoryTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            categoryTableViewController.selectedValue = self.categoryField.text
            categoryTableViewController.valueList = []
            for category in categories {
                categoryTableViewController.valueList?.append(category.name!)
            }
            
        default:
            // fatalError("Unexpected Segue Identifier: \(segue.identifier)")
            return
        }
    }
}

extension ExpenseDetailsViewController {
    @IBAction func unwindWithSelectedCategory(segue: UIStoryboardSegue) {
        if let pickerViewController = segue.source as? CategoryTableViewController {
            self.categoryField.text = pickerViewController.selectedValue
            for category in categories {
                if category.name == pickerViewController.selectedValue {
                    expense?.category = category
                    break
                }
            }
            updateSaveButtonState()
        }
    }
}
