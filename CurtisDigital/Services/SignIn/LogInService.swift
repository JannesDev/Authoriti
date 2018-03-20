//
//  LogInService.swift
//  CurtisDigital
//
//  Created by Jannes on 11/15/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit

protocol LogInService: BaseService {
    func userLoginSuccess()
    func userLoginFailed()
}

extension LogInService {
    
    func loginWith(_ account: AccountID, password: String, isSelected: Bool) {
        
        print(AppManager.sharedInstance.reachability!.connection)
        
        let accountIDs = UserPreference.currentUser.accounts.filter({$0.type == account.type})
        let keychain = KeychainManager()
        
        guard let storedData = keychain.getDataFromKeychain(Constant.Keys.keyPassword), UserAuth.token != "", let storedPassword = String.init(data: storedData, encoding: .utf8) else {
            self.loginWithEndpoint(account.id, password: password, selected: isSelected)
            return
        }
        
        if storedPassword == password, accountIDs.count > 0 {
            if isSelected {
                AppManager.sharedInstance.saveDefaultOptionsToUserDefault(.accountId, detailOption: nil, accountId: account.id, expireTime: nil, purpose: "account")
            } else if let defaultAccount = AppManager.sharedInstance.defaultOptionsFromUserDefault(.accountId, purpose: "account") as? AccountID, account.id == defaultAccount.id {
                AppManager.sharedInstance.saveDefaultOptionsToUserDefault(.accountId, detailOption: nil, accountId: "", expireTime: nil, purpose: "account")
            }
            
            self.userLoginSuccess()
            //self.showMessage("Login success")
        } else {
            self.userLoginFailed()
            self.showErrorMessage("Invalid username or password!")
        }
    }
    
    func loginWithEndpoint(_ account: String, password: String, selected: Bool) {
        if let connection = AppManager.sharedInstance.reachability?.connection, connection == .none {    // When Network is lost
            self.userLoginFailed()
            self.showMessage("No internet connection. Please try again later.")
        } else {                                                            // When Network is available.
            //Show Loading View
            self.showProgressHUD()
            
            let endpoint = URLBuilder.urlLogin
            let params = [
                APIKeys.Login.keyUser               : account,
                APIKeys.Login.keyPassword           : password
            ]
            
            print("User Login: endpoint - \(endpoint), params - \(params)")
            
            self.postUrl(endpoint, params: params, headers: nil) { (response, error) in
                // Hide Loading View
                self.hideProgressHUD()
                
                if let error = error {
                    self.showErrorMessage(error.localizedDescription)
                } else if let response = response {
                    print(response)
                    
                    if selected {
                        AppManager.sharedInstance.saveDefaultOptionsToUserDefault(.accountId, detailOption: nil, accountId: account, expireTime: nil, purpose: "account")
                    } else if let defaultAccount = AppManager.sharedInstance.defaultOptionsFromUserDefault(.accountId, purpose: "account") as? AccountID, account == defaultAccount.id {
                        AppManager.sharedInstance.saveDefaultOptionsToUserDefault(.accountId, detailOption: nil, accountId: "", expireTime: nil, purpose: "account")
                    }
                    
                    if let token = response[APIKeys.Login.keyAuthToken] as? String {
                        UserAuth.setUserToken(token)
                    }
                    
                    if let userInfo = response[APIKeys.Login.keyUser] as? [String: Any] {
                        UserPreference.currentUser.loadFromDictionary(userInfo)
                        UserPreference.currentUser.saveProfileToUserDefault()
                        
                        if let salt = userInfo["salt"] as? String {
                            let _ = AppManager.sharedInstance.generateKeyPair(password, salt: salt)
                        }
                        
                        UserAuth.setIsLoggedIn(true)
                        UserAuth.setLastTime()
                        
                        self.userLoginSuccess()
                    } else if let message = response["message"] as? String {
                        self.showErrorMessage(message)
                    }
                }
            }
        }
    }
}
