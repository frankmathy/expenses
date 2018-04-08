//
//  AccountPickerViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 28.02.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import UIKit

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
                CDAccountDAO.sharedInstance.save()
                Model.sharedInstance.loadAccounts()
                self.accounts = Model.sharedInstance.getAccounts()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
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
