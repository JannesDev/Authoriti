//
//  UserPreference.swift
//  CurtisDigital
//
//  Created by Jannes on 11/15/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit

class UserAuth {
    static var userId: String {
        get {
            guard let value = UserDefaults.standard.value(forKey: Constant.Keys.keyUserId) as? String else {
                return ""
            }
            return value
        }
    }
    
    static var token: String {
        get {
            guard let value = UserDefaults.standard.value(forKey: Constant.Keys.keyAuthToken) as? String else {
                return ""
            }
            return value
        }
    }
    
    static var isLoggedin: Bool {
        get {
            guard let value = UserDefaults.standard.value(forKey: Constant.Keys.keyIsLoggedIn) as? Bool else {
                return false
            }
            return value
        }
    }
    
    static var isTouchId: Bool {
        get {
            guard let value = UserDefaults.standard.value(forKey: Constant.Keys.keyIsTouchId) as? Bool else {
                return false
            }
            return value
        }
    }
    
    static var isChaseAccount: Bool {
        get {
            guard let value = UserDefaults.standard.value(forKey: Constant.Keys.keyIsChaseAccount) as? Bool else {
                return false
            }
            return value
        }
    }
    
    static var needLogin: Bool {
        get {
            guard let value = UserDefaults.standard.value(forKey: Constant.Keys.keyActiveLastTime) as? String else {
                return true
            }
            
            let timestamp = Double(value) ?? 0
            let current = Date().timeIntervalSince1970
            
            if current - timestamp > 300 {
                return true
            } else {
                return false
            }
        }
    }
    
    class func setLastTime() {
        let time = String(Date().timeIntervalSince1970)
        UserDefaults.standard.setValue(time, forKey: Constant.Keys.keyActiveLastTime)
        UserDefaults.standard.synchronize()
    }
    
    class func setUserId(_ userId: String) {
        UserDefaults.standard.setValue(userId, forKey: Constant.Keys.keyUserId)
        UserDefaults.standard.synchronize()
    }
    
    class func setUserToken(_ token: String) {
        UserDefaults.standard.setValue(token, forKey: Constant.Keys.keyAuthToken)
        UserDefaults.standard.synchronize()
    }
    
    class func setIsLoggedIn(_ isLoggedIn: Bool) {
        UserDefaults.standard.setValue(isLoggedIn, forKey: Constant.Keys.keyIsLoggedIn)
        UserDefaults.standard.synchronize()
    }
    
    class func setIsChaseAccount(_ isLoggedIn: Bool) {
        UserDefaults.standard.setValue(isLoggedIn, forKey: Constant.Keys.keyIsChaseAccount)
        UserDefaults.standard.synchronize()
    }
    
    class func setIsTouchId(_ isTouchId: Bool) {
        UserDefaults.standard.setValue(isTouchId, forKeyPath: Constant.Keys.keyIsTouchId)
        UserDefaults.standard.synchronize()
    }
    
    class func removeUserAuthFromUserDefault() {
        let userDefault = UserDefaults.standard
        if let _ = userDefault.object(forKey: Constant.Keys.keyUserId) {
            userDefault.removeObject(forKey: Constant.Keys.keyUserId)
        }
        
        if let _ = userDefault.object(forKey: Constant.Keys.keyAuthToken) {
            userDefault.removeObject(forKey: Constant.Keys.keyAuthToken)
        }
        
        if let _ = userDefault.object(forKey: Constant.Keys.keyIsLoggedIn) {
            userDefault.removeObject(forKey: Constant.Keys.keyIsLoggedIn)
        }
        
        if let _ = userDefault.object(forKey: Constant.Keys.keyIsChaseAccount) {
            userDefault.removeObject(forKey: Constant.Keys.keyIsChaseAccount)
        }
        
        if let _ = userDefault.object(forKey: Constant.Keys.keyIsTouchId) {
            userDefault.removeObject(forKey: Constant.Keys.keyIsTouchId)
        }
        
        if let _ = userDefault.object(forKey: Constant.Keys.keyActiveLastTime) {
            userDefault.removeObject(forKey: Constant.Keys.keyActiveLastTime)
        }
    }
    
    class func logout() {
        let userDefault = UserDefaults.standard
        if let _ = userDefault.object(forKey: Constant.Keys.keyIsLoggedIn) {
            userDefault.removeObject(forKey: Constant.Keys.keyIsLoggedIn)
        }
    }
}

class UserPreference: NSObject {
   
    var userId: String?
    var accounts: [AccountID] = [AccountID]()
    var password: String?
    var inviteCode: String?
    
    static let currentUser = UserPreference()
    
    override init() {
        super.init()
        
        self.loadUserProfileFromUserDefault()
    }
    
    // Create Instance From Dictionary
    //
    func loadFromDictionary(_ dict: [String: Any?]) {
        self.userId = dict["userId"] as? String
        self.accounts = [AccountID]()
        
        if let accountList = dict["accounts"] as? [[String: Any]] {
            for account in accountList {
                let accountId = AccountID(type: account["type"] as! String, id: account["value"] as! String)
                self.accounts.append(accountId)
            }
        }
    }
    
    // Create Dictionary Value
    //
    func getDictionaryValue() -> [String: Any?] {
        var dictionary: [String: Any?] = [ : ] as [String: Any?]
        
        var accountList: [[String: Any]] = [[String: Any]]()
        for account in self.accounts {
            let accountDict = ["type": account.type, "value": account.id]
            accountList.append(accountDict)
        }
        
        let accountData = NSKeyedArchiver.archivedData(withRootObject: accountList)
        dictionary["account"] = accountData
        
        return dictionary
    }
    
    // Save Profile Data To User Default
    //
    func saveProfileToUserDefault() {
        let dict = self.getDictionaryValue()
        UserDefaults.standard.setValue(dict, forKey: Constant.Keys.keyUserProfile)
        UserDefaults.standard.synchronize()
    }
    
    // Remove Profile Data From User Default
    //
    func removeProfileFromUserDefault() {
        self.accounts = [AccountID]()
        self.password = nil
        UserDefaults.standard.removeObject(forKey: Constant.Keys.keyUserProfile)
        UserDefaults.standard.synchronize()
    }
    
    
    func removeAccounts() {
        self.accounts = [AccountID]()
        UserDefaults.standard.removeObject(forKey: Constant.Keys.keyUserProfile)
        UserDefaults.standard.synchronize()
    }
    
    // Load User Profile From User Default
    //
    func loadUserProfileFromUserDefault() {
        guard let dict = UserDefaults.standard.dictionary(forKey: Constant.Keys.keyUserProfile) else {
            return
        }
        
        if let accountData = dict["account"] as? Data, let accountList = NSKeyedUnarchiver.unarchiveObject(with: accountData) as? [[String: Any]] {
            for account in accountList {
                let accountId = AccountID(type: account["type"] as! String, id: account["value"] as! String)
                self.accounts.append(accountId)
            }
        }
    }
}
