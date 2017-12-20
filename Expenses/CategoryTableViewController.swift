//
//  CategoryTableViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 19.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import UIKit

class CategoryTableViewController: UITableViewController {
    
    var selectedCell : UITableViewCell?
    
    var valueList : [String]?
    
    var selectedValue : String?

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let values = valueList else {
            return 0
        }
        return values.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        guard let values = valueList else {
            return cell
        }
        
        let value = values[indexPath.row]
        cell.textLabel?.text = value
        
        if(value == selectedValue) {
            cell.accessoryType = .checkmark
            selectedCell = cell
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "SaveCategory",
            let cell = sender as? UITableViewCell else {
                return
        }
        selectedValue = cell.textLabel?.text
    }
}
