//
//  DateTimePickerViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 20.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import UIKit

class DateTimePickerViewController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var date : Date?

    override func viewDidLoad() {
        if date != nil {
            datePicker.date = date!
        }
        datePicker.maximumDate = Date()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "SaveDate" else {
            return
        }
        date = datePicker.date
    }


}
