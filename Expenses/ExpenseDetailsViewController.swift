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
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var categoryField: UILabel!
    @IBOutlet weak var accountField: UILabel!
    @IBOutlet weak var projectField: UILabel!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // Types for picker controller
    static let TYPE_CATEGORY = "category"
    static let TYPE_ACCOUNT = "account"
    static let TYPE_PROJECT = "project"
    
    var editedTextField: UITextField?
    
    var expense: Expense?
    
    let categories = SampleData.getCategories()
    
    let accounts = SampleData.getAccounts()
    
    let projects = SampleData.getProjects()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTextField.addTarget(self, action: #selector(amountTextFieldDidChange), for: .editingChanged)
        commentField.addTarget(self, action: #selector(commentTextFieldDidChange), for: .editingChanged)

        if expense != nil {
            navigationItem.title = NSLocalizedString("Edit Expense", comment: "")
        } else {
            navigationItem.title = NSLocalizedString("Add Expense", comment: "")
            expense = Expense(date: Date(), category: SampleData.categoryGroceries, account: SampleData.accountHousehold, project: SampleData.projectNone, amount: 0.0, comment: "")
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
    
    private func updateSaveButtonState() {
        saveButton.isEnabled = expense!.amount != 0.0 && expense?.category != nil && expense?.account != nil && expense?.project != nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
        case "PickCategory":
            guard let pickerController = segue.destination as? NamedItemPickerViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            pickerController.title = "Category"
            pickerController.itemType = ExpenseDetailsViewController.TYPE_CATEGORY
            pickerController.selectedValue = expense?.category
            pickerController.valueList = categories

        case "PickAccount":
            guard let pickerController = segue.destination as? NamedItemPickerViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            pickerController.title = "Account"
            pickerController.itemType = ExpenseDetailsViewController.TYPE_ACCOUNT
            pickerController.selectedValue = expense?.account
            pickerController.valueList = accounts

        case "PickProject":
            guard let pickerController = segue.destination as? NamedItemPickerViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            pickerController.title = "Project"
            pickerController.itemType = ExpenseDetailsViewController.TYPE_PROJECT
            pickerController.selectedValue = expense?.project
            pickerController.valueList = projects
            
        case "PickDate":
            guard let datePickerController = segue.destination as? DateTimePickerViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            datePickerController.date = expense?.date
            
        default:
            // fatalError("Unexpected Segue Identifier: \(segue.identifier)")
            return
        }
    }
}

extension ExpenseDetailsViewController {
    @IBAction func unwindWithSelectedCategory(segue: UIStoryboardSegue) {
        if let pickerViewController = segue.source as? NamedItemPickerViewController {
            if pickerViewController.itemType == ExpenseDetailsViewController.TYPE_CATEGORY {
                expense?.category = pickerViewController.selectedValue!
                self.categoryField.text = expense?.category.name
                updateSaveButtonState()
            } else if pickerViewController.itemType == ExpenseDetailsViewController.TYPE_ACCOUNT {
                expense?.account = pickerViewController.selectedValue! as! Account
                self.accountField.text = expense?.account.name
                updateSaveButtonState()
            } else if pickerViewController.itemType == ExpenseDetailsViewController.TYPE_PROJECT {
                expense?.project = pickerViewController.selectedValue!
                self.projectField.text = expense?.project.name
                updateSaveButtonState()
            }
        }
    }
    
    @IBAction func unwindWithSelectedDate(segue: UIStoryboardSegue) {
        if let pickerController = segue.source as? DateTimePickerViewController {
            expense?.date = pickerController.date!
            dateField.text = expense!.date.asLocaleDateTimeString
        }
    }
}
