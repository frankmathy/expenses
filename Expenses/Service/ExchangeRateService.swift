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
    
    var exchangeRateCache = [String : ExchangeRate]()
    
    func getRate(baseCcy : String, termsCcy : String, completionHandler: @escaping (Double?, String?) -> Swift.Void) {
        let today = Date().asLocaleDateString
        
        var rate : ExchangeRate?
        
        // Try to get rate from local cache
        rate = exchangeRateCache[baseCcy + termsCcy]
        if rate != nil {
            // Update in GUI
            completionHandler(rate?.rate, nil)
            if rate?.recordDate?.asLocaleDateString == today {
                // Is from today --> return
                return
            }
        } else {
            // Try to get rates from local database
            let (exchangeRate, error) = CDExchangeRateDAO.sharedInstance.get(byCcyPair: baseCcy, termsCcy: termsCcy)
            if error != nil {
                print("Error reading exchange rate \(baseCcy)/\(termsCcy) from Core Data: \(error!.localizedDescription)")
            } else if exchangeRate != nil {
                // Store in cache
                exchangeRateCache[baseCcy + termsCcy] = exchangeRate
                
                // Show in GUI, even if outdated
                completionHandler(exchangeRate?.rate, nil)
                let rateDate = exchangeRate?.recordDate?.asLocaleDateString
                if rateDate == today {
                    // No further action if rate is from today
                    return
                }
            }
        }
        
        // Get rate from website
        getExchangeRatesFromFloatRates(forCurrency: termsCcy) { (ratesResultsMap, error) in
            guard error == nil else {
                completionHandler(nil, "No rate available")
                return
            }
            if ratesResultsMap != nil  {
                DispatchQueue.main.async {
                    let rateValue = ratesResultsMap![baseCcy]
                    if rateValue != nil {
                        completionHandler(rateValue, nil)
                    } else {
                        print("Currency pair \(baseCcy)/\(termsCcy) not available")
                        completionHandler(nil, "No rate available")
                    }
                    
                    // Store in local database
                    for (resultBaseCcy, rate) in ratesResultsMap! {
                        do {
                            let exchangeRate = try CDExchangeRateDAO.sharedInstance.addCurrentRate(baseCcy: resultBaseCcy, termsCcy: termsCcy, rateValue: rate)
                            self.exchangeRateCache[resultBaseCcy + termsCcy] = exchangeRate
                        } catch {
                            print("Error saving rate for \(resultBaseCcy)/\(termsCcy): \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    func getExchangeRatesFromFloatRates(forCurrency ccy : String, completionHandler: @escaping ([String : Double]?, Error?) -> Swift.Void) {
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
    
    func clearAllRates() {
        exchangeRateCache.removeAll()
        CDExchangeRateDAO.sharedInstance.removeAll()
        print("Rates cache and database cleared")
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
