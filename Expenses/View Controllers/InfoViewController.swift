//
//  InfoViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 01.01.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import UIKit
import MobileCoreServices

class InfoViewController: UIViewController, UIDocumentMenuDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate {

    @IBAction func importDataPressed(_ sender: UIButton) {
        let picker = UIDocumentPickerViewController(documentTypes: [kUTTypePlainText as String], in: .import)
        picker.delegate = self
        picker.modalPresentationStyle = .formSheet
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func deleteAllExpensesPressed(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("Expenses", comment: ""), message: NSLocalizedString("Delete all Expenses?", comment: ""), preferredStyle: .alert)
        let yes = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { (action) -> Void in
            Model.sharedInstance.deleteAllExpenses()
        })
        let no = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: { (action) -> Void in })
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if urls.count > 0 {
             do {
                let contents = try String(contentsOf: urls[0], encoding: String.Encoding.utf8)
                let rows = contents.components(separatedBy: "\n")
                let dateFormat = ISO8601DateFormatter()
                var imported = 0
                for row in rows {
                    let columns = row.components(separatedBy: "\t")
                    if columns.count >= 6 {
                        let date = dateFormat.date(from: columns[0])
                        let amount = (columns[1] as NSString).doubleValue
                        let accountName = columns[2]
                        let category = columns[3]
                        let project = columns[4]
                        let comment = columns[5]
                        Model.sharedInstance.addExpense(date: date!, categoryName: category, accountName: accountName, projectName: project, amount: amount, comment: comment)
                        imported = imported + 1
                    }
                }
                Model.sharedInstance.modelUpdated()
                Model.sharedInstance.setDateIntervalType(dateIntervalType: DateIntervalType.Week)
                ViewControllerUtils.showAlert(title: NSLocalizedString("Import succesful", comment: ""), message: String(format: NSLocalizedString("Imported d expenses from s", comment: ""), imported, (urls[0].lastPathComponent)), viewController: self)
             } catch {
                ViewControllerUtils.showAlert(title: NSLocalizedString("Error importing Expenses", comment: ""), message: String(format: NSLocalizedString("Importing from s failed.", comment: ""), (urls[0].lastPathComponent)), viewController: self)
             }
        }
    }
    
    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    }
}
