//
//  SampleData.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation

final class SampleData {
    let accountHousehold = Account(name: "Haushalt")
    let accountOther = Account(name: "Sonstiges")

    let categoryBarber = Category(name: "Friseur")
    let categoryBakery = Category(name: "Bäcker")
    let categorySupermarket = Category(name: "Supermarkt")

    let accounts: [Account];
    var categories: [Category]
    
    var expenses: [Expense]
    
    init() {
        accounts = [accountHousehold, accountOther]
        categories = [categorySupermarket, categoryBakery, categoryBarber]
        let today = Date()
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.day = -1
        let yesterday = calendar.date(byAdding: dateComponents, to: today)
        expenses = [
            Expense(date: yesterday!, category: categorySupermarket, account: accountHousehold, amount: 52.47, comment: "Essen Wochenende"),
            Expense(date: yesterday!, category: categoryBarber, account: accountOther, amount: 28.0, comment: "Basile Marvin"),
            Expense(date: today, category: categoryBakery, account: accountOther, amount: 4.95, comment: "Bäcker Klein")
        ]
    }
}
