//
//  SampleData.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation

final class SampleData {
    static let accountHousehold = "Haushalt"
    static let accountOther = "Restbudget"

    static let categoryCar = "Auto"
    static let categoryBakery = "Bäcker"
    static let categoryDrugstore = "Drogerie"
    static let categoryHobby = "Freizeit/Hobby"
    static let categoryBarber = "Friseur"
    static let categoryPresents = "Geschenke"
    static let categoryHealth = "Gesundheit"
    static let categoryClothes = "Kleidung"
    static let categoryGroceries = "Lebensmittel"
    static let categoryRestaurant = "Restaurant"
    static let categoryTransportation = "Transport"

    
    static let projectNone = "-"
    static let projectUrlaub = "Urlaub"
    
    static func getAccounts() -> [String] {
        return [accountHousehold, accountOther]
    }
    
    static func getCategories() -> [String] {
        return [categoryCar,categoryBakery,categoryDrugstore,categoryHobby,categoryBarber,categoryPresents,categoryHealth,categoryClothes,categoryGroceries,categoryRestaurant,categoryTransportation]
    }
    
    static func getProjects() -> [String] {
        return [projectNone, projectUrlaub]
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
            Expense(date: yesterday!, category: categoryGroceries, account: accountHousehold, project: projectNone, amount: 52.47, comment: "Essen Wochenende"),
            Expense(date: twoDaysAgo!, category: categoryBarber, account: accountOther, project: projectNone, amount: 28.0, comment: "Basile Marvin"),
            Expense(date: today, category: categoryBakery, account: accountOther, project: projectNone, amount: 4.95, comment: "Bäcker Klein"),
            Expense(date: yesterday!, category: categoryGroceries, account: accountHousehold, project: projectNone, amount: 52.47, comment: "Essen Wochenende"),
            Expense(date: twoDaysAgo!, category: categoryBarber, account: accountOther, project: projectNone, amount: 28.0, comment: "Basile Marvin"),
            Expense(date: today, category: categoryBakery, account: accountOther, project: projectNone, amount: 4.95, comment: "Bäcker Klein"),
        ]
        return expenses
    }
}
