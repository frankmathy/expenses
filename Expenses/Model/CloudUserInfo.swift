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
    var givenName : String?
    var familyName : String?
    var emailAddress : String?
    
    var userStatus : CKApplicationPermissionStatus?
    var userRecordId : CKRecordID?
}

