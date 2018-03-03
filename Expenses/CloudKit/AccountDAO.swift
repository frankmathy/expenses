//
//  AccountDAO.swift
//  Expenses
//
//  Created by Frank Mathy on 03.03.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation
import CloudKit

class AccountDAO {
    static let sharedInstance = AccountDAO()

    func load(completionHandler: @escaping ([Account]?, Error?) -> Swift.Void) {
        let privateDB = CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: Account.RecordTypeName, predicate: NSPredicate(value: true))
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            var accounts = [Account]()
            for record in records! {
                let account = Account(asNew: record)
                accounts.append(account)
            }
            completionHandler(accounts, error)
        }
    }
    
    func save(account : Account, completionHandler: @escaping (Account?, Error?) -> Swift.Void) {
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
