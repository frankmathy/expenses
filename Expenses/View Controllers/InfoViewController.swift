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
    
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var deleteAllButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBAction func importDataPressed(_ sender: UIButton) {
        let picker = UIDocumentPickerViewController(documentTypes: [kUTTypePlainText as String], in: .import)
        picker.popoverPresentationController?.barButtonItem = sender as! UIBarButtonItem
        picker.delegate = self
        picker.modalPresentationStyle = .formSheet
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func resetRatesPressed(_ sender: UIButton) {
        ExchangeRateService.sharedInstance.clearAllRates()
    }
    
    @IBAction func deleteAllExpensesPressed(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("Expenses", comment: ""), message: NSLocalizedString("Delete all Expenses?", comment: ""), preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = sender as! UIButton
        let yes = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { (action) -> Void in
            Model.sharedInstance.deleteAllExpenses()
        })
        let no = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: { (action) -> Void in })
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func helpButtonPressed(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: NSLocalizedString("HomepageUrl", comment: ""))!, options: [:], completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dictionary = Bundle.main.infoDictionary
        let version = dictionary!["CFBundleShortVersionString"] as! String
        let build = dictionary!["CFBundleVersion"] as! String
        versionLabel.text = "Version " + version + " build " + build
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
                    if columns.count >= 10 {
                        let date = dateFormat.date(from: columns[0])
                        let amount = (columns[1] as NSString).doubleValue
                        let accountName = columns[2]
                        let category = columns[3]
                        let project = columns[4]
                        let comment = columns[5]
                        var venueId : String? = nil
                        var venueName : String? = nil
                        var venueLat : Double = Double.nan
                        var venueLng : Double = Double.nan
                        if columns[6].count > 0 {
                            venueId = columns[6]
                            venueName = columns[7]
                            venueLat = (columns[8] as NSString).doubleValue
                            venueLng = (columns[9] as NSString).doubleValue
                        }
                        var currency : String? = SystemConfig.sharedInstance.appCurrencyCode
                        var exchangeRate = 1.0
                        if columns.count >= 12 {
                            currency = columns[10]
                            exchangeRate = (columns[11] as NSString).doubleValue
                        }
                        let expense = Model.sharedInstance.addExpense(date: date!, categoryName: category, accountName: accountName, projectName: project, amount: amount, comment: comment, venueId: venueId, venueName: venueName, venueLat: venueLat, venueLng: venueLng, currency: currency, exchangeRate : exchangeRate)
                        imported = imported + 1
                    }
                }
                Model.sharedInstance.reloadExpenses()
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
