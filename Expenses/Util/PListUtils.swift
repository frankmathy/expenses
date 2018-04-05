//
//  PlistUtils.swift
//  Expenses
//
//  Created by Frank Mathy on 06.04.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation

class PListUtils {
    static func loadDefaultValues(forResource : String, itemId : String) -> [String]? {
        let path = Bundle.main.path(forResource: forResource, ofType: "plist")
        let xml = NSData(contentsOfFile: path!)
        let datasourceDictionary = try! PropertyListSerialization.propertyList(from: xml! as Data, options: [], format: nil) as! [String : [String]]
        return datasourceDictionary[itemId]
    }
}
