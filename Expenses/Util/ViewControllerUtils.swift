//
//  GUIUtils.swift
//  Expenses
//
//  Created by Frank Mathy on 31.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import UIKit

class ViewControllerUtils {
    
    static func showAlert(title : String, message : String,  viewController : UIViewController) -> Void {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.sourceView = viewController.view
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func showTextEntryAlert(title : String, message : String, fieldName : String, fieldValue : String? = nil, viewController : UIViewController, onSavePressed : @escaping (_ inputString: String) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default) { (alertAction) in
            let nameField = alertController.textFields![0] as UITextField
            onSavePressed(nameField.text!)
        })
        
        alertController.addTextField { (textField) in
            textField.placeholder = fieldName
            textField.textAlignment = .left
            if fieldValue != nil {
                textField.text = fieldValue
            }
        }
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}

