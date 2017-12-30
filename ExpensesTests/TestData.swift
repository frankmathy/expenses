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
    let accountHousehold = Account(byName: "Haushalt")
    let accountOther = Account(byName: "Restbudget")
    let accounts: [NamedItem]

    let categoryCar = NamedItem(asCategory: "Auto")
    let categoryBakery = NamedItem(asCategory: "Bäcker")
    let categoryDrugstore = NamedItem(asCategory: "Drogerie")
    let categoryHobby = NamedItem(asCategory: "Freizeit/Hobby")
    let categoryBarber = NamedItem(asCategory: "Friseur")
    let categoryPresents = NamedItem(asCategory: "Geschenke")
    let categoryHealth = NamedItem(asCategory: "Gesundheit")
    let categoryClothes = NamedItem(asCategory: "Kleidung")
    let categoryGroceries = NamedItem(asCategory: "Lebensmittel")
    let categoryRestaurant = NamedItem(asCategory: "Restaurant")
    let categoryTransportation = NamedItem(asCategory: "Transport")
    let categories: [NamedItem]

    let projectNone = NamedItem(asProject: "-")
    let projectUrlaub = NamedItem(asProject: "Urlaub")
    let projects: [NamedItem]
    
    let today : Date
    let yesterday: Date
    let twoDaysAgo: Date
    
    let expenseYesterdayGroceries50: Expense
    let expenseTodayBarber20: Expense
    let expenseTodayBakery5: Expense
    let expenseYesterdayDoctor95: Expense
    let expenseseTwoDaysAgoBarber30: Expense
    let expenseTodayAppleStore200: Expense
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
        expenseYesterdayGroceries50 = Expense(date: yesterday, category: categoryGroceries, account: accountHousehold, project: projectNone, amount: 50.00, comment: "Essen Wochenende")
        expenseTodayBarber20 = Expense(date: today, category: categoryBarber, account: accountOther, project: projectNone, amount: 20.0, comment: "Basile Marvin")
        expenseTodayBakery5 = Expense(date: today, category: categoryBakery, account: accountOther, project: projectNone, amount: 5.0, comment: "Bäcker Klein")
        expenseYesterdayDoctor95 = Expense(date: yesterday, category: categoryHealth, account: accountHousehold, project: projectNone, amount: 95.0, comment: "Dr. Mastermind")
        expenseseTwoDaysAgoBarber30 = Expense(date: twoDaysAgo, category: categoryBarber, account: accountOther, project: projectNone, amount: 30.0, comment: "Basile Marvin")
        expenseTodayAppleStore200 = Expense(date: today, category: categoryHobby, account: accountOther, project: projectNone, amount: 200.0, comment: "Apple Store")
        expenses = [ expenseYesterdayGroceries50, expenseTodayBarber20, expenseTodayBakery5, expenseYesterdayDoctor95, expenseseTwoDaysAgoBarber30, expenseTodayAppleStore200 ]
    }
}
