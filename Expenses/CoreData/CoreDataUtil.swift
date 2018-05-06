//
//  CoreDataUtil.swift
//  Expenses
//
//  Created by Frank Mathy on 10.03.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataUtil {
    
    static let sharedInstance = CoreDataUtil()

    var managedObjectContext : NSManagedObjectContext? {
        get {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
            return appDelegate.persistentContainer.viewContext
        }
    }
    
    func saveChanges() throws {
        try managedObjectContext!.save()
    }
    
    func rollbackChanges() {
        managedObjectContext!.reset()
    }
}
