//
//  Project.swift
//  Expenses
//
//  Created by Frank Mathy on 29.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation
import os.log

class Project: NSObject, NSCoding {
    var name: String
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
    }
    
    
    init?(name: String) {
        guard !name.isEmpty else {
            return nil
        }
        self.name = name
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Project object.", log: OSLog.default, type:.error)
            return nil
        }
        self.init(name: name)
    }

}
