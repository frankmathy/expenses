//
//  AccountDAO.swift
//  Expenses
//
//  Created by Frank Mathy on 03.03.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation
import CloudKit

class CKAccountDAO {
    static let sharedInstance = CKAccountDAO()

    func load(completionHandler: @escaping ([CKAccount]?, Error?) -> Swift.Void) {
        let privateDB = CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: CKAccount.RecordTypeName, predicate: NSPredicate(value: true))
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            var accounts = [CKAccount]()
            for record in records! {
                let account = CKAccount(asNew: record)
                accounts.append(account)
            }
            completionHandler(accounts, error)
        }
    }
    
    func save(account : CKAccount, completionHandler: @escaping (CKAccount?, Error?) -> Swift.Void) {
        let privateDB = CKContainer.default().privateCloudDatabase
        privateDB.save(account.record) { (record, error) in
            guard error == nil else {
                completionHandler(account, error)
                return
            }
            completionHandler(account, error)
        }
    }
}
