//
//  ExchangeRateService.swift
//  Expenses
//
//  Created by Frank Mathy on 04.03.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation

class ExchangeRateService {

    let availableCurrencies = ["EUR", "USD", "GBP", "JPY", "CHF", "AUD", "BGN", "BRL", "CAD", "CNY", "CZK", "DKK", "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PLN", "RON", "RUB", "SEK", "SGD", "THB", "TRY", "ZAR"]
    
    func getRate(baseCcy : String, termsCcy : String, completionHandler: @escaping (Double?, String?) -> Swift.Void) {
        // https://api.fixer.io/latest?base=EUR&symbols=JPY
        let urlString = "https://api.fixer.io/latest?base=\(baseCcy)&symbols=\(termsCcy)"
        guard let url = URL(string: urlString) else {
            print("Url \(urlString) is not valid")
            return
        }
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                completionHandler(nil, error!.localizedDescription)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let errorMessage = "Error fetching data, HTTP status code \(httpResponse.statusCode)"
                    print(errorMessage)
                    completionHandler(nil, errorMessage)
                    return
                }
            }
            guard let data = data else {
                let errorMessage = "No data received"
                print(errorMessage)
                completionHandler(nil, errorMessage)
                return
            }
            do {
                guard let exchangeDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                    let errorMessage = "Could not convert JSON to dictionary"
                    print(errorMessage)
                    completionHandler(nil, errorMessage)
                    return
                }
                if let rates = exchangeDict["rates"], let rate = rates[termsCcy] as? Double {
                    completionHandler(rate, nil)
                } else {
                    let errorMessage = "No rate for \(termsCcy) in result"
                    print(errorMessage)
                    completionHandler(nil, errorMessage)
                }
            }
            catch {
                let errorMessage = "Error trying to convert JSON to dictionary"
                print(errorMessage)
                completionHandler(nil, errorMessage)
            }
        }
        task.resume()
    }
}
