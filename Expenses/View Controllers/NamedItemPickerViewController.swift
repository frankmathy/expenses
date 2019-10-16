//
//  NamedItemPickerViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 19.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import UIKit

class NamedItemPickerViewController: UITableViewController {

    // Types for picker controller
    static let TYPE_CATEGORIES = "categories"
    static let TYPE_ACCOUNTS = "accounts"
    static let TYPE_PROJECTS = "projects"
    
    var itemType : String?
    
    var selectedCell : UITableViewCell?
    
    var valueList : [NamedItem]?
    
    var selectedValue : String?
    
    override func viewDidLoad() {
        reloadData()
    }

    func reloadData() {
        let (namedItems, error) =
        CDNamedItemDAO.sharedInstance.load(itemType: itemType!)
        guard error == nil else {
            let message = NSLocalizedString("Error loading NamedItem from iCloud", comment: "")
            print("\(message): \(error!)")
            return
        }
        self.valueList = namedItems
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let values = valueList else {
            return 0
        }
        return values.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NamedItemCell", for: indexPath)

        guard let values = valueList else {
            return cell
        }
        
        let value = values[indexPath.row].itemName
        cell.textLabel?.text = value
        
        if(value == selectedValue) {
            cell.accessoryType = .checkmark
            selectedCell = cell
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = self.valueList![indexPath.row]
            CDNamedItemDAO.sharedInstance.delete(item: item)
            self.valueList?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "SaveCategory",
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) else {
                return
        }

        selectedValue = valueList![indexPath.row].itemName
    }
    
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        ViewControllerUtils.showTextEntryAlert(title: NSLocalizedString("Add New Item", comment: ""), message: NSLocalizedString("Enter Item Name.", comment: ""), fieldName: NSLocalizedString("Name", comment: ""), viewController: self) { (itemString) in
            if itemString != "" {
                let newItem = CDNamedItemDAO.sharedInstance.create()
                newItem?.itemName = itemString
                newItem?.listName = self.itemType
                self.valueList?.insert(newItem!, at: 0)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                do {
                    try CoreDataUtil.sharedInstance.saveChanges()
                } catch {
                    // TODO Error handling
                    print("Error adding named item: \(error.localizedDescription)")
                }
            }
        }
    }
}
