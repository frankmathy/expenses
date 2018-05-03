//
//  ExchangeRateService.swift
//  Expenses
//
//  Created by Frank Mathy on 04.03.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation
import CoreData

class ExchangeRateService {

    static let sharedInstance = ExchangeRateService()
    
    static let availableCurrencies = ["EUR", "USD", "GBP", "JPY", "CHF", "AUD", "BGN", "BRL", "CAD", "CNY", "CZK", "DKK", "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PLN", "RON", "RUB", "SEK", "SGD", "THB", "TRY", "ZAR"]
    
    var exchangeRateCache : [String : Double]?
    
    func getRate(baseCcy : String, termsCcy : String, completionHandler: @escaping (Double?, String?) -> Swift.Void) {
        if exchangeRateCache == nil {
            getExchangeRates(forCurrency: termsCcy) { (ratesResultsMap, error) in
                guard error == nil else {
                    completionHandler(0.0, error?.localizedDescription)
                    return
                }
                self.exchangeRateCache = ratesResultsMap
                guard let rate = self.exchangeRateCache![baseCcy] else {
                    completionHandler(nil, "No rate available")
                    return
                }
                completionHandler(rate, nil)
            }
        } else {
            guard let rate = exchangeRateCache![baseCcy] else {
                completionHandler(nil, "No rate available")
                return
            }
            completionHandler(rate, nil)
        }
    }
    
    func getExchangeRates(forCurrency ccy : String, completionHandler: @escaping ([String : Double]?, Error?) -> Swift.Void) {
        let urlString = "https://www.floatrates.com/daily/\(ccy).json"
        guard let url = URL(string: urlString) else {
            print("Url \(urlString) is not valid")
            return
        }
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                completionHandler(nil, error)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let errorMessage = "Error fetching data, HTTP status code \(httpResponse.statusCode)"
                    print(errorMessage)
                    completionHandler(nil, error)
                    return
                }
            }
            guard let data = data else {
                let errorMessage = "No data received"
                print(errorMessage)
                completionHandler(nil, NSError(domain: errorMessage, code: 1, userInfo: nil))
                return
            }
            var ratesByCcy = [String : Double]()
            do {
                let json = try JSON(data: data)
                for (_,subJson):(String, JSON) in json {
                    let code = subJson["code"].string
                    let inverseRate = subJson["rate"].double
                    ratesByCcy[code!] = 1.0 / inverseRate!
                }
                completionHandler(ratesByCcy, nil)
            }
            catch {
                let errorMessage = "Error trying to convert JSON to dictionary"
                print(errorMessage)
                completionHandler(nil, NSError(domain: errorMessage, code: 1, userInfo: nil))
            }
        }
        task.resume()
    }
    
    static func getSymbol(forCurrencyCode code: String) -> String? {
        let locale = NSLocale(localeIdentifier: code)
        if locale.displayName(forKey: .currencySymbol, value: code) == code {
            let newlocale = NSLocale(localeIdentifier: code.characters.dropLast() + "_en")
            return newlocale.displayName(forKey: .currencySymbol, value: code)
        }
        return locale.displayName(forKey: .currencySymbol, value: code)
    }
}
