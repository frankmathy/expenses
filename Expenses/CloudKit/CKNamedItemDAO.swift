//
//  NamedItemDAO.swift
//  Expenses
//
//  Created by Frank Mathy on 01.03.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation
import CloudKit

class CKNamedItemDAO {
    
    static let sharedInstance = CKNamedItemDAO()
    
    func save(item : CKNamedItem) {
        let privateDB = CKContainer.default().privateCloudDatabase
        privateDB.save(item.record, completionHandler: { (record, error) in
            guard error == nil else {
                let message = NSLocalizedString("Error saving new named item", comment: "")
                print("\(message): \(error!)")
                return
            }
            print("Successfully saved new named item with ID=\(record!.recordID)")
        })
    }
    
    func load(itemType : String, completionHandler: @escaping ([CKNamedItem]?, Error?) -> Swift.Void) {
        let privateDB = CKContainer.default().privateCloudDatabase
        
        var valueList = [CKNamedItem]()
        
        let predicate = NSPredicate(format: "ListName = %@", itemType)
        let query = CKQuery(recordType: CKNamedItem.RecordTypeName, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: CKNamedItem.nameColumnName, ascending: true)]
        privateDB.perform(query, inZoneWith: nil) { results,error in
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            if results!.count > 0 {
                for record in results! {
                    valueList.append(CKNamedItem(recordTypeName: itemType, record: record))
                }
            }
            completionHandler(valueList, error)
        }
    }
    
    func delete(item : CKNamedItem) {
        let privateDB = CKContainer.default().privateCloudDatabase
        privateDB.delete(withRecordID: item.record.recordID, completionHandler: { (recordId, error) in
            guard error == nil else {
                let message = NSLocalizedString("Error deleting named item", comment: "")
                print("\(message): \(error!)")
                return
            }
        })
    }
}
