//
//  NamedItem.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation
import Firebase

class NamedItem {
    var key: String
    var name: String
    
    //MARK: Types
    struct PropertyKey {
        static let key = "key"
        static let name = "name"
    }

    init(name: String) {
        self.key = ""
        self.name = name
    }
    
    init(snapshot: DataSnapshot) {
        self.key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.name = snapshotValue[PropertyKey.name] as! String
    }
    
    func toAnyObject() -> Any {
        return [
            PropertyKey.name: name
        ]
    }
}
