//
//  Category.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

class Category {
    var name: String?
    
    init?(name: String) {
        guard !name.isEmpty else {
            return nil
        }
        self.name = name
    }
}
