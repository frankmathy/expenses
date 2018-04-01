//
//  NamedItem.swift
//  Expenses
//
//  Created by Frank Mathy on 18.02.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation
import CloudKit

class CKNamedItem {
    
    static let RecordTypeName = "NamedItem"
    static let nameColumnName = "ItemName"
    static let listColumnName = "ListName"
    
    var record : CKRecord
    
    var name: String {
        get {
            return record[CKNamedItem.nameColumnName] as! String
        }
        
        set(newComment) {
            record[CKNamedItem.nameColumnName] = newComment as CKRecordValue
        }
    }
    
    var list: String {
        get {
            return record[CKNamedItem.listColumnName] as! String
        }
        
        set(listName) {
            record[CKNamedItem.listColumnName] = listName as CKRecordValue
        }
    }
    
    init(list: String, name: String) {
        record = CKRecord(recordType: CKNamedItem.RecordTypeName)
        self.list = list
        self.name = name
    }
    
    init(recordTypeName : String, record: CKRecord) {
        self.record = record
    }
}
