//
//  TestData.swift
//  ExpensesTests
//  Test data for unit testing
//
//  Created by Frank Mathy on 22.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation


class TestData {
    let accountHousehold = NamedItem(name: "Haushalt")
    let accountOther = NamedItem(name: "Restbudget")
    let accounts: [NamedItem]

    let categoryCar = NamedItem(name: "Auto")
    let categoryBakery = NamedItem(name: "Bäcker")
    let categoryDrugstore = NamedItem(name: "Drogerie")
    let categoryHobby = NamedItem(name: "Freizeit/Hobby")
    let categoryBarber = NamedItem(name: "Friseur")
    let categoryPresents = NamedItem(name: "Geschenke")
    let categoryHealth = NamedItem(name: "Gesundheit")
    let categoryClothes = NamedItem(name: "Kleidung")
    let categoryGroceries = NamedItem(name: "Lebensmittel")
    let categoryRestaurant = NamedItem(name: "Restaurant")
    let categoryTransportation = NamedItem(name: "Transport")
    let categories: [NamedItem]

    let projectNone = NamedItem(name: "-")
    let projectUrlaub = NamedItem(name: "Urlaub")
    let projects: [NamedItem]
    
    let today : Date
    let yesterday: Date
    let twoDaysAgo: Date
    
    let expenseYesterdayGroceries: Expense
    let expenseTodayBarber: Expense
    let expenseTodayBakery: Expense
    let expenseYesterdayDoctor: Expense
    let expenseseTwoDaysAgoBarber: Expense
    let expenseTodayAppleStore: Expense
    let expenses: [Expense]

    init() {
        accounts = [accountHousehold, accountOther]
        categories = [categoryCar, categoryBakery, categoryDrugstore, categoryHobby, categoryBarber, categoryPresents, categoryHealth, categoryClothes, categoryGroceries, categoryRestaurant, categoryTransportation]
        projects = [projectNone, projectUrlaub]
        today = Date()
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.day = -1
        yesterday = calendar.date(byAdding: dateComponents, to: today)!
        dateComponents.day = -2
        twoDaysAgo = calendar.date(byAdding: dateComponents, to: today)!
        expenseYesterdayGroceries = Expense(date: yesterday, category: categoryGroceries, account: accountHousehold, project: projectNone, amount: 52.47, comment: "Essen Wochenende")
        expenseTodayBarber = Expense(date: today, category: categoryBarber, account: accountOther, project: projectNone, amount: 28.0, comment: "Basile Marvin")
        expenseTodayBakery = Expense(date: today, category: categoryBakery, account: accountOther, project: projectNone, amount: 4.95, comment: "Bäcker Klein")
        expenseYesterdayDoctor = Expense(date: yesterday, category: categoryHealth, account: accountHousehold, project: projectNone, amount: 52.47, comment: "Dr. Mastermind")
        expenseseTwoDaysAgoBarber = Expense(date: twoDaysAgo, category: categoryBarber, account: accountOther, project: projectNone, amount: 28.0, comment: "Basile Marvin")
        expenseTodayAppleStore = Expense(date: today, category: categoryHobby, account: accountOther, project: projectNone, amount: 4.95, comment: "Apple Store")
        expenses = [ expenseYesterdayGroceries, expenseTodayBarber, expenseTodayBakery, expenseYesterdayDoctor, expenseseTwoDaysAgoBarber, expenseTodayAppleStore ]
    }
}
