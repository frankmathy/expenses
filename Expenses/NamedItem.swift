//
//  NamedItem.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation

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
    
    func toAnyObject() -> Any {
        return [
            PropertyKey.name: name
        ]
    }
}
