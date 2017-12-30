//
//  Account.swift
//  Expenses
//
//  Created by Frank Mathy on 30.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation
import CloudKit

class Account : NamedItem {
    init(byName name : String) {
        super.init(recordTypeName: NamedItem.RecordNameAccount, name: name)
    }
    
    init(record : CKRecord) {
        super.init(recordTypeName: NamedItem.RecordNameAccount, record: record)
    }
}
