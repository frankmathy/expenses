//
//  NamedItemPickerViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 19.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import UIKit
import CloudKit

class NamedItemPickerViewController: UITableViewController {

    static let RECORD_TYPE_NAME = "NamedItem"

    // Types for picker controller
    static let TYPE_CATEGORIES = "categories"
    static let TYPE_ACCOUNTS = "accounts"
    static let TYPE_PROJECTS = "projects"
    
    var itemType : String?
    
    var selectedCell : UITableViewCell?
    
    var valueList : [NamedItem]?
    
    var selectedValue : String?
    
    override func viewDidLoad() {
        let publicDB = CKContainer.default().publicCloudDatabase

        valueList = []
        
        let predicate = NSPredicate(format: "ListName = %@", itemType!)
        let query = CKQuery(recordType: NamedItemPickerViewController.RECORD_TYPE_NAME, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: NamedItem.nameColumnName, ascending: true)]
        publicDB.perform(query, inZoneWith: nil) { [unowned self] results,error in
            guard error == nil else {
                let message = NSLocalizedString("Error loading NamedItem from iCloud", comment: "")
                print("\(message): \(error!)")
                return
            }
            if results!.count > 0 {
                for record in results! {
                    self.valueList?.append(NamedItem(recordTypeName: self.itemType!, record: record))
                }
            } else {
                // Initialize with default values
                let itemStrings: [String]
                switch self.itemType! {
                case NamedItemPickerViewController.TYPE_ACCOUNTS:
                    itemStrings = SampleData.getAccounts()
                case NamedItemPickerViewController.TYPE_PROJECTS:
                    itemStrings = SampleData.getProjects()
                case NamedItemPickerViewController.TYPE_CATEGORIES:
                    itemStrings = SampleData.getCategories()
                default:
                    fatalError("Unexpected item type: \(self.itemType!)")
                    return
                }
                for itemString in itemStrings {
                    let newItem = NamedItem(list: self.itemType!, name: itemString)
                    self.valueList?.append(newItem)
                    publicDB.save(newItem.record, completionHandler: { (record, error) in
                        guard error == nil else {
                            let message = NSLocalizedString("Error saving named item", comment: "")
                            print("\(message): \(error!)")
                            return
                        }
                        print("Successfully saved named item with ID=\(record?.recordID)")
                    })
                }
            }
            
            // Update table
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
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
        
        let value = values[indexPath.row].name
        cell.textLabel?.text = value
        
        if(value == selectedValue!) {
            cell.accessoryType = .checkmark
            selectedCell = cell
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "SaveCategory",
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) else {
                return
        }

        selectedValue = valueList![indexPath.row].name
    }
}
