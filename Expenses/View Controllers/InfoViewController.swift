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

    @IBAction func exportDataPressed(_ sender: UIButton) {
        let csv = Model.sharedInstance.CSV()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd HHmmss"
        let fileName = "Expenses " + formatter.string(from: Date()) + ".txt"
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        do {
            try csv.write(to: path, atomically: true, encoding: String.Encoding.utf8)
            let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
            vc.excludedActivityTypes = [
                UIActivityType.assignToContact,
                UIActivityType.saveToCameraRoll,
                UIActivityType.postToFlickr,
                UIActivityType.postToVimeo,
                UIActivityType.postToTencentWeibo,
                UIActivityType.postToTwitter,
                UIActivityType.postToFacebook,
                UIActivityType.openInIBooks
            ]
            present(vc, animated: true, completion: nil)
        } catch {
        }
    }
    
    @IBAction func importDataPressed(_ sender: UIButton) {
        let picker = UIDocumentPickerViewController(documentTypes: [kUTTypePlainText as String], in: .import)
        picker.delegate = self
        picker.modalPresentationStyle = .formSheet
        self.present(picker, animated: true, completion: nil)
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
                        let amount = (columns[1] as NSString).floatValue
                        let account = columns[2]
                        let category = columns[3]
                        let project = columns[4]
                        let comment = columns[5]
                        let expense = Expense(date: date!, category: category, account: account, project: project, amount: amount, comment: comment)
                        Model.sharedInstance.updateExpense(expense: expense)
                        imported = imported + 1
                    }
                 }
                 ViewControllerUtils.showAlert(title: "Import succesful", message: "Imported \((imported)) expenses from \(urls[0].lastPathComponent)", viewController: self)
             } catch {
                 ViewControllerUtils.showAlert(title: "Error importing Expenses", message: "Importing from \(urls[0].lastPathComponent) failed.", viewController: self)
             }
        }
    }
    
    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentMenuWasCancelled(_ documentMenu: UIDocumentMenuViewController) {
        print("Cancelled")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
