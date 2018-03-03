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
    @IBOutlet weak var createdByAt: UILabel!
    @IBOutlet weak var editedByAt: UILabel!
    
    var editedTextField: UITextField?
    
    var expense: Expense?
    
    var newExpense : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTextField.addTarget(self, action: #selector(amountTextFieldDidChange), for: .editingChanged)
        commentField.addTarget(self, action: #selector(commentTextFieldDidChange), for: .editingChanged)

        if newExpense! {
            navigationItem.title = NSLocalizedString("Add Expense", comment: "")
            expense = Expense(date: Date(), category: SampleData.categoryGroceries, account:  Model.sharedInstance.getDefaultAccount()!, project: SampleData.projectNone, amount: 0.0, comment: "")
        } else {
            navigationItem.title = NSLocalizedString("Edit Expense", comment: "")
        }
        amountTextField.text = expense!.amount.currencyInputFormatting()
        dateField.text = expense!.date.asLocaleDateTimeString
        categoryField.text = expense!.category
        accountField.text = expense!.account?.accountName
        projectField.text = expense!.project
        commentField.text = expense!.comment
        
        // Show creation details if available
        let creatorUserRecordId = expense!.creatorUserRecordID
        let creationDate = expense!.creationDate
        if creatorUserRecordId != nil && creationDate != nil {
            Model.sharedInstance.cloudUserInfo.getUserInfoByRecordName(recordName: creatorUserRecordId!, completionHandler: { (userInfo, error) in
                DispatchQueue.main.async {
                    if error == nil {
                        let name = (userInfo?.givenName!)! + " " + (userInfo?.familyName!)!
                        let dateString = (creationDate?.asLocaleDateLongTimeString)!
                        self.createdByAt.text = "Created by \(name) at \(dateString)"
                    } else {
                        self.createdByAt.text = ""
                    }
                }
            })
        } else {
            createdByAt.text = ""
        }
        
        // Show modification details if available
        let lastModifiedUserRecordId = expense!.lastModifiedUserRecordID
        let modificationDate = expense!.modificationDate
        if lastModifiedUserRecordId != nil && modificationDate != nil && modificationDate != creationDate {
            Model.sharedInstance.cloudUserInfo.getUserInfoByRecordName(recordName: lastModifiedUserRecordId!, completionHandler: { (userInfo, error) in
                DispatchQueue.main.async {
                    if error == nil {
                        let name = (userInfo?.givenName!)! + " " + (userInfo?.familyName!)!
                        let dateString = (modificationDate?.asLocaleDateLongTimeString)!
                        self.editedByAt.text = "Modified by \(name) at \(dateString)"
                    } else {
                        self.editedByAt.text = ""
                    }
                }
            })
        } else {
            editedByAt.text = ""
        }

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
            let nav = segue.destination as? UINavigationController
            guard let pickerController = nav?.topViewController as? NamedItemPickerViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            pickerController.title = NSLocalizedString("Category", comment: "")
            pickerController.itemType = NamedItemPickerViewController.TYPE_CATEGORIES
            pickerController.selectedValue = expense?.category

        case "PickProject":
            let nav = segue.destination as? UINavigationController
            guard let pickerController = nav?.topViewController as? NamedItemPickerViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            pickerController.title = NSLocalizedString("Project", comment: "")
            pickerController.itemType = NamedItemPickerViewController.TYPE_PROJECTS
            pickerController.selectedValue = expense?.project
            
        case "PickDate":
            guard let datePickerController = segue.destination as? DateTimePickerViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            datePickerController.date = expense?.date
            
        case "PickAccount":
            let nav = segue.destination as? UINavigationController
            guard let pickerController = nav?.topViewController as? AccountPickerViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            pickerController.selectedValue = expense?.account
            
        default:
            // fatalError("Unexpected Segue Identifier: \(segue.identifier)")
            return
        }
    }
}

extension ExpenseDetailsViewController {
    @IBAction func unwindWithSelectedCategory(segue: UIStoryboardSegue) {
        if let pickerViewController = segue.source as? NamedItemPickerViewController {
            if pickerViewController.itemType == NamedItemPickerViewController.TYPE_CATEGORIES {
                expense?.category = pickerViewController.selectedValue!
                self.categoryField.text = expense?.category
                updateSaveButtonState()
            } else if pickerViewController.itemType == NamedItemPickerViewController.TYPE_PROJECTS {
                expense?.project = pickerViewController.selectedValue!
                self.projectField.text = expense?.project
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
    
    @IBAction func unwindCancelExpenseNamedItem(segue: UIStoryboardSegue) {
    }
    
    @IBAction func unwindWithSelectedAccount(segue: UIStoryboardSegue) {
        if let accountController = segue.source as? AccountPickerViewController {
            expense?.account = accountController.selectedValue
            print(expense?.account?.accountName)
            self.accountField.text = expense?.account?.accountName
            updateSaveButtonState()
        }
    }
    
    @IBAction func unwindCancelExpenseAccount(segue: UIStoryboardSegue) {
    }
}
