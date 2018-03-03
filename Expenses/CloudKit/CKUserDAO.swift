//
//  CKUserDAO.swift
//  Expenses
//
//  Created by Frank Mathy on 03.03.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation
import CloudKit

class CKUserDAO {
    
    static let sharedInstance = CKUserDAO()

    func getUserInfo(recordName : String, completionHandler: @escaping (CloudUserInfo?, Error?) -> Swift.Void) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: CKRecordID(recordName: recordName)) { (userIdentity, error) in
            guard error == nil else {
                print("Could not load user info for recordName \(recordName)")
                completionHandler(nil, error)
                return
            }
            let info = CloudUserInfo()
            info.emailAddress = userIdentity?.lookupInfo?.emailAddress
            info.givenName = userIdentity?.nameComponents?.givenName
            info.familyName = userIdentity?.nameComponents?.familyName
            completionHandler(info, nil)
        }
    }
    
    func getCurrentUserInfo(completionHandler: @escaping (CloudUserInfo?, Error?) -> Swift.Void) {
        // Test code: Load user info
        CKContainer.default().requestApplicationPermission(.userDiscoverability) { (status, error) in
            switch status
            {
            case .granted:
                print("iCloud is OK")
                
            case .initialState:
                print("The user has not yet decided whether to grant this permission")
                return
                
            case .couldNotComplete:
                print("An error occurred during the getting or setting of the app permission")
                if let error = error
                {
                    print("err @ \(#function) -> \(error.localizedDescription)")
                }
                return
                
            case .denied:
                print("The user denied access to the permission.")
                return
            }
            
            CKContainer.default().fetchUserRecordID { (recordId, error) in
                guard error == nil else {
                    print("Error fetching current user id" + error.debugDescription)
                    completionHandler(nil, error)
                    return
                }
                self.getUserInfo(recordName: (recordId?.recordName)!, completionHandler: completionHandler)
            }
        }
    }
}
