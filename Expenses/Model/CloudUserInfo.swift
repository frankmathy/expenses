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
    
    struct ApplicationUserInfo {
        var givenName : String?
        var familyName : String?
        var emailAddress : String?
    }
    
    var userStatus : CKApplicationPermissionStatus?
    var userRecordId : CKRecordID?
    var currentUser = ApplicationUserInfo()
    
    var userInfoByRecordName = [String : ApplicationUserInfo]()
    
    func getUserInfoByRecordName(recordName : String, completionHandler: @escaping (ApplicationUserInfo?, Error?) -> Void) -> Void {
        var info = userInfoByRecordName[recordName]
        if info != nil {
            completionHandler(info, nil)
        } else {
            CKContainer.default().discoverUserIdentity(withUserRecordID: CKRecordID(recordName: recordName), completionHandler: { (userIdentity, error) in
                if error == nil {
                    info = ApplicationUserInfo()
                    info?.emailAddress = userIdentity?.lookupInfo?.emailAddress
                    info?.givenName = userIdentity?.nameComponents?.givenName
                    info?.familyName = userIdentity?.nameComponents?.familyName
                    print("User with recordName=\(recordName) has name= \(info!.givenName!) \(info!.familyName!)")
                    self.userInfoByRecordName[recordName] = info
                    completionHandler(info, nil)
                } else {
                    print("User with recordName=\(recordName) not found, error: "
                        + (error?.localizedDescription)!)
                    completionHandler(nil, error)
                }
            })
        }
    }
    
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
                    print("User ID: \(recordId!.recordName)")
                } else {
                    print("Error querying user: " + (error?.localizedDescription)!)
                }
                self.getUserInfoByRecordName(recordName: (recordId?.recordName)!, completionHandler: { (userInfo, error) in
                    if error == nil {
                        self.currentUser = userInfo!
                    }
                })
            }
        }
    }
}

