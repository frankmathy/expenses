//
//  AccountPickerViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 28.02.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import UIKit
import Firebase

class AccountPickerViewController: UITableViewController {

    var selectedCell : UITableViewCell?
    
    var accounts : [Account] = []
    
    var selectedValue : Account?
    
    override func viewDidLoad() {
        accounts = Model.sharedInstance.getAccounts()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)
        let value = accounts[indexPath.row]
        cell.textLabel?.text = value.accountName
        
        if(selectedValue != nil && value.accountName == selectedValue!.accountName) {
            cell.accessoryType = .checkmark
            selectedCell = cell
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    @IBAction func onAddButtonPressed(_ sender: UIBarButtonItem) {
        ViewControllerUtils.showTextEntryAlert(title: NSLocalizedString("Add New Account", comment: ""), message: NSLocalizedString("Enter Account Name.", comment: ""), fieldName: NSLocalizedString("Name", comment: ""), viewController: self) { (itemString) in
            if itemString != "" {
                let account = CDAccountDAO.sharedInstance.create()
                account?.currencyCode = SystemConfig.sharedInstance.appCurrencyCode
                account?.currencySymbol = SystemConfig.sharedInstance.appCurrencySymbol
                account?.accountName = itemString
                do {
                    try CoreDataUtil.sharedInstance.saveChanges()
                } catch {
                    // TODO Proper error handling: Show message to user
                    print("Error saving account: \(error.localizedDescription)")
                    return
                }
                Model.sharedInstance.loadAccounts()
                self.accounts = Model.sharedInstance.getAccounts()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                Analytics.logEvent("account_edited", parameters: ["action" : "add" as NSObject])
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { (action, indexPath) in
            let account = self.accounts[indexPath.row]
            let cell = tableView.cellForRow(at: indexPath)
            self.deleteAccount(account: account, cell: cell!)
        }
        deleteAction.backgroundColor = .red

        let renameAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Edit", comment: "")) { (action, indexPath) in
            let account = self.accounts[indexPath.row]
            self.editAccount(account: account)
        }
        renameAction.backgroundColor = .blue
        
        return [renameAction, deleteAction]
    }
    
    func deleteAccount(account : Account, cell : UITableViewCell) {
        let alert = UIAlertController(title: NSLocalizedString("Expenses", comment: ""), message: NSLocalizedString("Delete account", comment: "")  + account.accountName! + "?", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = cell
        let yes = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { (action) -> Void in
            CDAccountDAO.sharedInstance.delete(account: account)
            Model.sharedInstance.loadAccounts()
            self.accounts = Model.sharedInstance.getAccounts()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            Analytics.logEvent("account_edited", parameters: ["action" : "delete" as NSObject])
        })
        let no = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: { (action) -> Void in })
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
    }
    
    func editAccount(account : Account) {
        ViewControllerUtils.showTextEntryAlert(title: NSLocalizedString("Edit account", comment: ""), message: NSLocalizedString("Enter new account name.", comment: ""), fieldName: NSLocalizedString("Name", comment: ""), fieldValue: account.accountName, viewController: self) { (itemString) in
            if itemString != "" {
                account.accountName = itemString
                do {
                    try CoreDataUtil.sharedInstance.saveChanges()
                } catch {
                    // TODO Proper error handling - show message to user
                    print("Error saving account: \(error.localizedDescription)")
                    return
                }
                Model.sharedInstance.loadAccounts()
                self.accounts = Model.sharedInstance.getAccounts()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                Analytics.logEvent("account_edited", parameters: ["action" : "rename" as NSObject])
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "SaveAccount",
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) else {
                return
        }
        
        selectedValue = accounts[indexPath.row]
    }
}
