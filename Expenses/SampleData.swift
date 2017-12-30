//
//  SampleData.swift
//  Expenses
//
//  Created by Frank Mathy on 26.11.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation

final class SampleData {
    static let accountHousehold = Account(byName: "Haushalt")
    static let accountOther = Account(byName: "Restbudget")

    static let categoryCar = NamedItem(asCategory: "Auto")
    static let categoryBakery = NamedItem(asCategory: "Bäcker")
    static let categoryDrugstore = NamedItem(asCategory: "Drogerie")
    static let categoryHobby = NamedItem(asCategory: "Freizeit/Hobby")
    static let categoryBarber = NamedItem(asCategory: "Friseur")
    static let categoryPresents = NamedItem(asCategory: "Geschenke")
    static let categoryHealth = NamedItem(asCategory: "Gesundheit")
    static let categoryClothes = NamedItem(asCategory: "Kleidung")
    static let categoryGroceries = NamedItem(asCategory: "Lebensmittel")
    static let categoryRestaurant = NamedItem(asCategory: "Restaurant")
    static let categoryTransportation = NamedItem(asCategory: "Transport")

    
    static let projectNone = NamedItem(asProject: "-")
    static let projectUrlaub = NamedItem(asProject: "Urlaub")
    
    static func getAccounts() -> [NamedItem] {
        return [accountHousehold, accountOther]
    }
    
    static func getCategories() -> [NamedItem] {
        return [categoryCar,categoryBakery,categoryDrugstore,categoryHobby,categoryBarber,categoryPresents,categoryHealth,categoryClothes,categoryGroceries,categoryRestaurant,categoryTransportation]
    }
    
    static func getProjects() -> [NamedItem] {
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
