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
    
    var valueList : [String]?
    
    var selectedValue : String?
    
    override func viewDidLoad() {
        valueList = []
        
        
        
        
        switch itemType! {
        case NamedItemPickerViewController.TYPE_ACCOUNTS:
            valueList = SampleData.getAccounts()
        case NamedItemPickerViewController.TYPE_PROJECTS:
            valueList = SampleData.getProjects()
        case NamedItemPickerViewController.TYPE_CATEGORIES:
            valueList = SampleData.getProjects()
        default:
            fatalError("Unexpected item type: \(itemType)")
            return
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
        
        let value = values[indexPath.row]
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
        
        selectedValue = valueList![indexPath.row]
    }
}
