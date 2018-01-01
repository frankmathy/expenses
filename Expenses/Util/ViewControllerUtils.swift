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
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        viewController.present(alertController, animated: true, completion: nil)
    }
}

