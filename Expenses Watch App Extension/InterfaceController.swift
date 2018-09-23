//
//  InterfaceController.swift
//  Expenses Watch App Extension
//
//  Created by Frank Mathy on 22.09.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    private var session: WCSession?
    @IBOutlet weak var dateRangeLabel: WKInterfaceLabel!
    @IBOutlet weak var amountField: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if(WCSession.isSupported()) {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WatchkitSession activated with state \(activationState)")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("Watchkit: Received application context")
        let dateRange = applicationContext["dateRange"] as? String
        if dateRange != nil {
            dateRangeLabel.setText(dateRange)
        }
        let amount = applicationContext["amount"] as? String
        if amount != nil {
            amountField.setText(amount)
        }
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }

}
