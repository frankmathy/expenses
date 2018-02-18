//
//  NamedItem.swift
//  Expenses
//
//  Created by Frank Mathy on 18.02.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation
import CloudKit

class NamedItem {
    
    static let RecordTypeName = "NamedItem"
    static let nameColumnName = "ItemName"
    static let listColumnName = "ListName"
    
    var record : CKRecord
    
    var recordId: CKRecordID? {
        get {
            return record.recordID
        }
    }
    
    var name: String {
        get {
            return record[NamedItem.nameColumnName] as! String
        }
        
        set(newComment) {
            record[NamedItem.nameColumnName] = newComment as CKRecordValue
        }
    }
    
    var list: String {
        get {
            return record[NamedItem.listColumnName] as! String
        }
        
        set(listName) {
            record[NamedItem.listColumnName] = listName as CKRecordValue
        }
    }
    
    init(list: String, name: String) {
        record = CKRecord(recordType: NamedItem.RecordTypeName)
        self.list = list
        self.name = name
    }
    
    init(recordTypeName : String, record: CKRecord) {
        self.record = record
    }
}
