//
//  NamedItem.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation
import CloudKit

class NamedItem {
    
    struct ColumnKey {
        static let key = "key"
        static let name = "Name"
    }
    
    static let RecordNameCategory = "Category"
    static let RecordNameAccount = "Account"
    static let RecordNameProject = "Project"

    let recordTypeName : String
    
    var record : CKRecord
    
    var recordId: CKRecordID? {
        get {
            return record.recordID
        }
    }
    
    var name: String {
        get {
            return record[ColumnKey.name] as! String
        }
        
        set(newComment) {
            record[ColumnKey.name] = newComment as CKRecordValue
        }
    }
    
    convenience init(asAccount name: String) {
        self.init(recordTypeName: NamedItem.RecordNameAccount, name: name)
    }
    
    convenience init(asCategory name: String) {
        self.init(recordTypeName: NamedItem.RecordNameCategory, name: name)
    }
    
    convenience init(asProject name: String) {
        self.init(recordTypeName: NamedItem.RecordNameProject, name: name)
    }
    
    init(recordTypeName : String, name: String) {
        self.recordTypeName = recordTypeName
        record = CKRecord(recordType: recordTypeName)
        self.name = name
    }
    
    init(recordTypeName : String, record: CKRecord) {
        self.recordTypeName = recordTypeName
        self.record = record
    }
}
