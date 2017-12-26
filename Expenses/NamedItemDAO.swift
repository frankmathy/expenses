//
//  NamedItemDAO.swift
//
//  Created by Frank Mathy on 22.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation

protocol NamedItemObserver {
    func namedItemsChanged(namedItems: [NamedItem])
}

class NamedItemDAO {
    
    var observers = [NamedItemObserver]()
    
    init(path : String) {
    }
    
    func addObserver(observer : NamedItemObserver) {
        observers.append(observer)
    }
    
    func observeExpenses() {
    }
    
    func add(namedItem: NamedItem) {
    }
    
    func update(namedItem: NamedItem) {
    }
    
    func remove(namedItem: NamedItem) {
    }
}

