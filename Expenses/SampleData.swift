//
//  SampleData.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation

final class SampleData {
    static let accountHousehold = Account(name: "Haushalt")
    static let accountOther = Account(name: "Sonstiges")

    static let categoryBarber = Category(name: "Friseur")
    static let categoryBakery = Category(name: "Bäcker")
    static let categorySupermarket = Category(name: "Supermarkt")
    static let categoryFillingStation = Category(name: "Tankstelle")
    
    static let projectNone = Project(name: "-")
    
    static func getAccounts() -> [Account] {
        return [accountHousehold, accountOther]
    }
    
    static func getCategories() -> [Category] {
        return [categorySupermarket!, categoryBakery!, categoryBarber!, categoryFillingStation!]
    }
    
    static func getProjects() -> [Project] {
        return [projectNone]
    }

    static func getExpenses() -> [Expense] {
        let today = Date()
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.day = -1
        let yesterday = calendar.date(byAdding: dateComponents, to: today)
        dateComponents.day = -2
        let twoDaysAgo = calendar.date(byAdding: dateComponents, to: today)
        let expenses = [
            Expense(date: yesterday!, category: categorySupermarket!, account: accountHousehold, project: projectNone, amount: 52.47, comment: "Essen Wochenende"),
            Expense(date: twoDaysAgo!, category: categoryBarber!, account: accountOther, project: projectNone, amount: 28.0, comment: "Basile Marvin"),
            Expense(date: today, category: categoryBakery!, account: accountOther, project: projectNone, amount: 4.95, comment: "Bäcker Klein"),
            Expense(date: yesterday!, category: categorySupermarket!, account: accountHousehold, project: projectNone, amount: 52.47, comment: "Essen Wochenende"),
            Expense(date: twoDaysAgo!, category: categoryBarber!, account: accountOther, project: projectNone, amount: 28.0, comment: "Basile Marvin"),
            Expense(date: today, category: categoryBakery!, account: accountOther, project: projectNone, amount: 4.95, comment: "Bäcker Klein"),
        ]
        return expenses
    }
}
