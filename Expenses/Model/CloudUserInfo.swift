//
//  CloudKitUtil.swift
//  Expenses
//
//  Created by Frank Mathy on 26.12.17.
//  Copyright © 2017 Frank Mathy. All rights reserved.
//

import Foundation
import CloudKit

class CloudUserInfo {
    
    var userStatus : CKApplicationPermissionStatus?
    var userRecordId : CKRecordID?
    var givenName : String?
    var familyName : String?
    var emailAddress : String?
    
    func loadUserInfo() {
        // Test code: Load user info
        CKContainer.default().requestApplicationPermission(.userDiscoverability) { (status, error) in
            self.userStatus = status
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
                self.userRecordId = recordId
                if error == nil {
                    print("User ID: \(recordId?.recordName)")
                } else {
                    print("Error querying user: " + (error?.localizedDescription)!)
                }
                
                CKContainer.default().discoverUserIdentity(withUserRecordID: recordId!, completionHandler: { (userIdentity, error) in
                    if error == nil {
                        self.emailAddress = userIdentity?.lookupInfo?.emailAddress
                        self.givenName = userIdentity?.nameComponents?.givenName
                        self.familyName = userIdentity?.nameComponents?.familyName
                        
                        print("Has iCloud Account = \(userIdentity?.hasiCloudAccount)")
                        print("Phone Number: \(userIdentity?.lookupInfo?.phoneNumber)")
                        print("Email Address: \(userIdentity?.lookupInfo?.emailAddress)")
                        print("Name: \((userIdentity?.nameComponents?.givenName)!) \((userIdentity?.nameComponents?.familyName)!)")
                    } else {
                        self.emailAddress = nil
                        self.givenName = nil
                        self.familyName = nil
                        
                        print("Error querying user details: " + (error?.localizedDescription)!)
                    }
                })
            }
        }
    }
}

