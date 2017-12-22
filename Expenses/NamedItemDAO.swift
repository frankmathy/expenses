//
//  NamedItemDAO.swift
//
//  Created by Frank Mathy on 22.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation
import Firebase

protocol NamedItemObserver {
    func namedItemsChanged(namedItems: [NamedItem])
}

class NamedItemDAO {
    
    let namedItemDBReference : DatabaseReference
    
    var observers = [NamedItemObserver]()
    
    init(path : String) {
        namedItemDBReference = Database.database().reference(withPath: path)
    }
    
    func addObserver(observer : NamedItemObserver) {
        observers.append(observer)
    }
    
    func observeExpenses() {
        namedItemDBReference.removeAllObservers()
        namedItemDBReference.observe(.value, with: { (snapshot) in
            var namedItems: [NamedItem] = []
            for entry in snapshot.children {
                let namedItem = NamedItem(snapshot: entry as! DataSnapshot)
                namedItems.append(namedItem)
            }
            for observer in self.observers {
                observer.namedItemsChanged(namedItems: namedItems)
            }
        })
    }
    
    func add(namedItem: NamedItem) {
        let newItemRef = namedItemDBReference.childByAutoId()
        namedItem.key = newItemRef.key
        newItemRef.setValue(namedItem.toAnyObject())
    }
    
    func update(namedItem: NamedItem) {
        let namedItemRef = namedItemDBReference.child(namedItem.key)
        namedItemRef.setValue(namedItem.toAnyObject())
    }
    
    func remove(namedItem: NamedItem) {
        namedItemDBReference.child(namedItem.key).removeValue()
    }
}

