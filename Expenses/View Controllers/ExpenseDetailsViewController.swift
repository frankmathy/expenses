//
//  ExpenseDetailsViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 28.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import UIKit
import MapKit
import Instructions
import ActionSheetPicker_3_0

class ExpenseDetailsViewController: UITableViewController, CoachMarksControllerDataSource, CoachMarksControllerDelegate {

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var convertedAmountField: UILabel!
    @IBOutlet weak var convertedAmountCell: UITableViewCell!
    @IBOutlet weak var currencyLabel: UIButton!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var categoryField: UILabel!
    @IBOutlet weak var accountField: UILabel!
    @IBOutlet weak var projectField: UILabel!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var createdByAt: UILabel!
    @IBOutlet weak var editedByAt: UILabel!
    @IBOutlet weak var locationField: UILabel!
    
    var editedTextField: UITextField?
    
    var expense: Expense?
    
    var newExpense : Bool?
    
    let coachMarksController = CoachMarksController()
    
    let helpTextIds = [ "Help.ExpenseDetails.General", "Help.ExpenseDetails.Location", "Help.ExpenseDetails.Comment", "Help.ExpenseDetails.Save" ]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.coachMarksController.dataSource = self
        amountTextField.addTarget(self, action: #selector(amountTextFieldDidChange), for: .editingChanged)
        commentField.addTarget(self, action: #selector(commentTextFieldDidChange), for: .editingChanged)

        if newExpense! {
            let config = SystemConfig.sharedInstance
            navigationItem.title = NSLocalizedString("Add Expense", comment: "")
            expense = CDExpensesDAO.sharedInstance.create()
            expense?.date = Date()
            if config.lastCategory != nil {
                expense?.category = config.lastCategory
            } else {
                let (categories, error) = CDNamedItemDAO.sharedInstance.load(itemType: NamedItemPickerViewController.TYPE_CATEGORIES)
                if error == nil && categories != nil && (categories?.count)! > 0 {
                    expense?.category = categories?[0].itemName
                    config.lastCategory = expense?.category
                }
            }
            expense?.account = Model.sharedInstance.getDefaultAccount()
            if let accountName = config.lastAccount {
                expense?.account = Model.sharedInstance.getAccount(accountName: accountName)
            }
            if config.lastProject != nil {
                expense?.project = config.lastProject
            } else {
                let (projects, error) = CDNamedItemDAO.sharedInstance.load(itemType: NamedItemPickerViewController.TYPE_PROJECTS)
                if error == nil && projects != nil && (projects?.count)! > 0 {
                    expense?.project = projects?[0].itemName
                    config.lastProject = expense?.project
                }
            }
            expense?.amount = 0.0
            expense?.amountForeignCcy = 0.0
            expense?.currency = SystemConfig.sharedInstance.appCurrencyCode
            expense?.comment = ""
        } else {
            navigationItem.title = NSLocalizedString("Edit Expense", comment: "")
            if expense?.currency == nil {
                expense?.currency = SystemConfig.sharedInstance.appCurrencyCode
            }
        }
        amountTextField.text = expense!.amountForeignCcy.asLocaleCurrency
        dateField.text = expense!.date!.asLocaleDateTimeString
        categoryField.text = expense!.category
        accountField.text = expense!.account?.accountName
        projectField.text = expense!.project
        commentField.text = expense!.comment
        updateCurrencyButton()
        updateLocationField()
        reCalculateAmount()
        updateSaveButtonState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        amountTextField.becomeFirstResponder()
        if !SystemConfig.sharedInstance.expenseDetailsScreenHelpWasDisplayed {
            SystemConfig.sharedInstance.expenseDetailsScreenHelpWasDisplayed = true
            self.coachMarksController.start(on: self)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.coachMarksController.stop(immediately: true)
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return helpTextIds.count
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch index {
        case 0:
            return coachMarksController.helper.makeCoachMark(for: amountTextField)
        case 1:
            return coachMarksController.helper.makeCoachMark(for: locationField)
        case 2:
            return coachMarksController.helper.makeCoachMark(for: commentField)
        case 3:
            let s = saveButton?.value(forKey: "view") as! UIView
            return coachMarksController.helper.makeCoachMark(for: s)
        default:
            return coachMarksController.helper.makeCoachMark(for: self.view)
        }
    }
    
    private func createInvisibleImage(cellFrame: CGRect) -> UIImageView {
        let overlayImage = UIImageView(frame: cellFrame)
        overlayImage.image = UIImage(named: "arrow_horiz_right_short")
        overlayImage.contentMode = .center
        overlayImage.isHidden=true
        return overlayImage
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        coachViews.bodyView.hintLabel.text = NSLocalizedString(helpTextIds[index], comment: "")
        coachViews.bodyView.nextLabel.text = NSLocalizedString(index < helpTextIds.count-1  ? "Next" : "Done", comment: "")
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    @IBAction func onHelpButtonPressed(_ sender: UIBarButtonItem) {
        self.coachMarksController.start(on: self)
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
        if let amountString = textField.text?.decimalInputFormatting() {
            textField.text = amountString
            expense?.amountForeignCcy = amountString.parseCurrencyValue()
            reCalculateAmount()
            updateSaveButtonState()
        }
    }
    
    fileprivate func updateCurrencyButton() {
        let currencySymbol = ExchangeRateService.getSymbol(forCurrencyCode: (expense?.currency)!)
        currencyLabel.setTitle(currencySymbol != nil ? currencySymbol : expense?.currency, for: .normal)
    }
    
    func reCalculateAmount() {
        let accountCurrency = SystemConfig.sharedInstance.appCurrencyCode
        if expense?.currency == accountCurrency {
            expense?.amount = (expense?.amountForeignCcy)!
            convertedAmountCell.isHidden = true
        } else {
            let exchangeService = ExchangeRateService()
            exchangeService.getRate(baseCcy: (expense?.currency)!, termsCcy: accountCurrency) { (rate, errorMessage) in
                if errorMessage != nil {
                    print("Error getting exchange rates: " + errorMessage!)
                    return
                }
                self.expense?.amount = (self.expense?.amountForeignCcy)! * rate!
                DispatchQueue.main.async {
                    self.convertedAmountCell.isHidden = false
                    self.convertedAmountField.text = (self.expense?.amount.asLocaleCurrency)! + " " + ExchangeRateService.getSymbol(forCurrencyCode: accountCurrency)!
                }
            }
        }
    }
    
    
    @objc func commentTextFieldDidChange(_ textField: UITextField) {
        if let comment = textField.text {
            expense?.comment = comment
            updateSaveButtonState()
        }
    }
    
    @IBAction func currencyButtonPressed(_ sender: UIButton) {
        let currencies = ExchangeRateService.availableCurrencies
        let selection = currencies.index(of: (expense?.currency)!)
        ActionSheetStringPicker.show(withTitle: "Expense Currency", rows: currencies, initialSelection: selection != nil ? selection! : 0, doneBlock: {
            picker, selectedIndex, selectedValue in
            self.expense?.currency = selectedValue as! String
            self.updateCurrencyButton()
            self.reCalculateAmount()
            return
        }, cancel: {_ in }, origin: sender)
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
            pickerController.title = NSLocalizedString("Category", comment: "")
            pickerController.itemType = NamedItemPickerViewController.TYPE_CATEGORIES
            pickerController.selectedValue = expense?.category

        case "PickProject":
            guard let pickerController = segue.destination as? NamedItemPickerViewController else {
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
            guard let pickerController = segue.destination as? AccountPickerViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            pickerController.selectedValue = expense?.account
            
        case "PickLocation":
            guard let pickerController = segue.destination as? EditLocationViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            pickerController.venueId = expense?.venueId
            pickerController.venueName = expense?.venueName
            pickerController.venueLng = expense?.venueLng
            pickerController.venueLat = expense?.venueLat
            
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
            dateField.text = expense!.date?.asLocaleDateTimeString
        }
    }
    
    @IBAction func unwindCancelExpenseNamedItem(segue: UIStoryboardSegue) {
    }
    
    @IBAction func unwindCancelLocation(segue: UIStoryboardSegue) {
    }

    @IBAction func unwindCancelDate(segue: UIStoryboardSegue) {
    }

    @IBAction func unwindWithSelectedAccount(segue: UIStoryboardSegue) {
        if let accountController = segue.source as? AccountPickerViewController {
            expense?.account = accountController.selectedValue
            self.accountField.text = expense?.account?.accountName
            updateSaveButtonState()
        }
    }
    
    @IBAction func unwindCancelExpenseAccount(segue: UIStoryboardSegue) {
    }
    
    @IBAction func unwindWithSelectedLocation(segue: UIStoryboardSegue) {
        if let pickerController = segue.source as? EditLocationViewController {
            expense?.venueId = pickerController.venueId
            expense?.venueName = pickerController.venueName
            expense?.venueLng = pickerController.venueLng!
            expense?.venueLat = pickerController.venueLat!
        }
        updateLocationField()
    }
    
    func updateLocationField() {
        if expense?.venueName == nil {
            locationField.text = "-"
        } else {
            locationField.text = expense?.venueName
        }
    }
    
    @IBAction func unwindResetLocation(segue: UIStoryboardSegue) {
        expense?.venueName = nil
        expense?.venueId = nil
        expense?.venueLng = Double.nan
        expense?.venueLat = Double.nan
        updateLocationField()
    }

}
