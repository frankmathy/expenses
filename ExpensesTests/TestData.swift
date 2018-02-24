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
    let accountHouseholdName = "Haushalt"
    let accountOtherName = "Restbudget"
    let accounts: [Account]

    let categoryCar = "Auto"
    let categoryBakery = "Bäcker"
    let categoryDrugstore = "Drogerie"
    let categoryHobby = "Freizeit/Hobby"
    let categoryBarber = "Friseur"
    let categoryPresents = "Geschenke"
    let categoryHealth = "Gesundheit"
    let categoryClothes = "Kleidung"
    let categoryGroceries = "Lebensmittel"
    let categoryRestaurant = "Restaurant"
    let categoryTransportation = "Transport"
    let categories: [String]

    let projectNone = "-"
    let projectUrlaub = "Urlaub"
    let projects: [String]
    
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
        categories = [categoryCar, categoryBakery, categoryDrugstore, categoryHobby, categoryBarber, categoryPresents, categoryHealth, categoryClothes, categoryGroceries, categoryRestaurant, categoryTransportation]
        projects = [projectNone, projectUrlaub]
        today = Date()
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.day = -1
        yesterday = calendar.date(byAdding: dateComponents, to: today)!
        dateComponents.day = -2
        twoDaysAgo = calendar.date(byAdding: dateComponents, to: today)!
        let accountHousehold = Account(accountName: accountHouseholdName)
        let accountOther = Account(accountName: accountOtherName)
        accounts = [accountHousehold, accountOther]
        expenseYesterdayGroceries50 = Expense(date: yesterday, category: categoryGroceries, account: accountHousehold, project: projectNone, amount: 50.00, comment: "Essen Wochenende")
        expenseTodayBarber20 = Expense(date: today, category: categoryBarber, account: accountOther, project: projectNone, amount: 20.0, comment: "Basile Marvin")
        expenseTodayBakery5 = Expense(date: today, category: categoryBakery, account: accountOther, project: projectNone, amount: 5.0, comment: "Bäcker Klein")
        expenseYesterdayDoctor95 = Expense(date: yesterday, category: categoryHealth, account: accountHousehold, project: projectNone, amount: 95.0, comment: "Dr. Mastermind")
        expenseseTwoDaysAgoBarber30 = Expense(date: twoDaysAgo, category: categoryBarber, account: accountOther, project: projectNone, amount: 30.0, comment: "Basile Marvin")
        expenseTodayAppleStore200 = Expense(date: today, category: categoryHobby, account: accountOther, project: projectNone, amount: 200.0, comment: "Apple Store")
        expenses = [ expenseYesterdayGroceries50, expenseTodayBarber20, expenseTodayBakery5, expenseYesterdayDoctor95, expenseseTwoDaysAgoBarber30, expenseTodayAppleStore200 ]
    }
}
