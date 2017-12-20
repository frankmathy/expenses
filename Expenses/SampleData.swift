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
    static let accountOther = Account(name: "Restbudget")

    static let categoryCar = NamedItem(name: "Auto")
    static let categoryBakery = NamedItem(name: "Bäcker")
    static let categoryDrugstore = NamedItem(name: "Drogerie")
    static let categoryHobby = NamedItem(name: "Freizeit/Hobby")
    static let categoryBarber = NamedItem(name: "Friseur")
    static let categoryPresents = NamedItem(name: "Geschenke")
    static let categoryHealth = NamedItem(name: "Gesundheit")
    static let categoryClothes = NamedItem(name: "Kleidung")
    static let categoryGroceries = NamedItem(name: "Lebensmittel")
    static let categoryRestaurant = NamedItem(name: "Restaurant")
    static let categoryTransportation = NamedItem(name: "Transport")

    
    static let projectNone = Project(name: "-")
    static let projectUrlaub = Project(name: "Urlaub")
    
    static func getAccounts() -> [Account] {
        return [accountHousehold!, accountOther!]
    }
    
    static func getCategories() -> [NamedItem] {
        return [categoryCar!,categoryBakery!,categoryDrugstore!,categoryHobby!,categoryBarber!,categoryPresents!,categoryHealth!,categoryClothes!,categoryGroceries!,categoryRestaurant!,categoryTransportation!]
    }
    
    static func getProjects() -> [Project] {
        return [projectNone!, projectUrlaub!]
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
            Expense(date: yesterday!, category: categoryGroceries!, account: accountHousehold!, project: projectNone!, amount: 52.47, comment: "Essen Wochenende"),
            Expense(date: twoDaysAgo!, category: categoryBarber!, account: accountOther!, project: projectNone!, amount: 28.0, comment: "Basile Marvin"),
            Expense(date: today, category: categoryBakery!, account: accountOther!, project: projectNone!, amount: 4.95, comment: "Bäcker Klein"),
            Expense(date: yesterday!, category: categoryGroceries!, account: accountHousehold!, project: projectNone!, amount: 52.47, comment: "Essen Wochenende"),
            Expense(date: twoDaysAgo!, category: categoryBarber!, account: accountOther!, project: projectNone!, amount: 28.0, comment: "Basile Marvin"),
            Expense(date: today, category: categoryBakery!, account: accountOther!, project: projectNone!, amount: 4.95, comment: "Bäcker Klein"),
        ]
        return expenses
    }
}
