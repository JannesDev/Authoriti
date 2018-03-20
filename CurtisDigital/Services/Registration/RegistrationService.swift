//
//  RegistrationService.swift
//  CurtisDigital
//
//  Created by Jannes on 11/14/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit

@objc protocol RegistrationService: BaseService {
    @objc optional func userSignUpSuccess(_ response: [String: Any])
    @objc optional func userSignUpFailed()
    
    @objc optional func userUpdateInfoSuccess(_ response: [String: Any])
    @objc optional func userUpdateInfoFailed()
    
    @objc optional func validationFailed()
    @objc optional func validationSuccess(_ isValid: Bool, customer: String)
    
    @objc optional func userConfirmSuccess(_ account: String)
    @objc optional func userConfirmFailed()
}

extension RegistrationService {
    
    func validateInviteCode(_ code: String) {
        if let connection = AppManager.sharedInstance.reachability?.connection, connection == .none {    // When Network is lost
            self.validationFailed?()
            self.showMessage("No internet connection. Please try again later.")
        } else {
            // Show Loading View
            self.showProgressHUD()
            
            let endpoint = URLBuilder.urlInviteCode
            let headers = [APIKeys.Header.keyContentType: "application/json"]
            
            // TODO: - Generate Key Pair
            
            let params = [
                APIKeys.SignUp.keyInviteCode        : code
                ] as [String : Any]
            
            self.postUrl(endpoint, params: params, headers: headers) { (response, error) in
                
                // Hide Loading View
                self.hideProgressHUD()
                
                if let error = error {
                    self.showErrorMessage(error.localizedDescription)
                    self.validationFailed?()
                } else if let response = response {
                    if let valid = response["valid"] as? Bool, valid {
                        self.validationSuccess!(valid, customer: response["customer"] as? String ?? "")
                    } else {
                        self.showErrorMessage(Messages.SignUp.msgInvalideCode)
                    }
                } else {
                    self.showErrorMessage(Messages.SignUp.msgInvalideCode)
                    self.validationFailed?()
                }
            }
        }
    }
    
    func userSignUpWith() {
        if let connection = AppManager.sharedInstance.reachability?.connection, connection == .none {    // When Network is lost
            self.userSignUpFailed?()
            self.showMessage("No internet connection. Please try again later.")
        } else {
            // Show Loading View
            self.showProgressHUD()
            
            let endpoint = URLBuilder.urlSignUp
            let headers = [APIKeys.Header.keyContentType: "application/json"]
            
            let userProfile = UserPreference.currentUser
            
            // TODO: - Generate Key Pair
            let keys = AppManager.sharedInstance.generateKeyPair(userProfile.password ?? "")
            
            var accountList: [[String: Any]] = [[String: Any]]()
            for account in userProfile.accounts {
                let accountDict = ["type": account.type, "value": account.id]
                accountList.append(accountDict)
            }
            
            let params = [
                APIKeys.SignUp.keyPassword          : userProfile.password ?? "",
                APIKeys.SignUp.keyRegisterKey       : keys.publicKey,
                APIKeys.SignUp.keySalt              : keys.salt,
                APIKeys.SignUp.keyAccountId         : accountList,
                APIKeys.SignUp.keyInviteCode        : userProfile.inviteCode ??  ""
                ] as [String : Any]
            
            self.postUrl(endpoint, params: params, headers: headers) { (response, error) in
                
                // Hide Loading View
                self.hideProgressHUD()
                
                if let error = error {
                    self.showErrorMessage(error.localizedDescription)
                    self.userSignUpFailed!()
                } else if let response = response {
                    
                    if let token = response[APIKeys.Login.keyAuthToken] as? String {
                        UserAuth.setUserToken(token)
                    } else {
                        self.userSignUpFailed!()
                    }
                    
                    if let _ = response[APIKeys.Login.keyUser] as? [String: Any] {
                        userProfile.saveProfileToUserDefault()
                        
                        KeychainManager().makeEncryptionKey(userProfile.password ?? "")
                        KeychainManager().saveDataToKeychainWith(keys.privateKey, key: Constant.Keys.keyPrivate)
                        KeychainManager().saveDataToKeychainWith(keys.salt, key: Constant.Keys.keySalt)
                        KeychainManager().saveDataToKeychainWith(userProfile.password ?? "", key: Constant.Keys.keyPassword)
                        
                        self.userSignUpSuccess!(response)
                    } else if let message = response["message"] as? String {
                        self.showErrorMessage(message)
                    }
                } else {
                    self.showErrorMessage(Messages.SignUp.msgSignUpFailed)
                    self.userSignUpFailed!()
                }
            }
        }
    }
    
    func userSignUpWithCustomer(_ account: AccountID) {
        if let connection = AppManager.sharedInstance.reachability?.connection, connection == .none {    // When Network is lost
            self.userSignUpFailed?()
            self.showMessage("No internet connection. Please try again later.")
        } else {
            // Show Loading View
            self.showProgressHUD()
            
            let endpoint = URLBuilder.urlSignUp
            let headers = [APIKeys.Header.keyContentType: "application/json"]
            
            let userProfile = UserPreference.currentUser
            userProfile.removeAccounts()
            UserAuth.setIsChaseAccount(false)
            
            // TODO: - Generate Key Pair
            DispatchQueue.global().async {
                let keys = AppManager.sharedInstance.generateKeyPair(userProfile.password ?? "")
                DispatchQueue.main.async {
                    var accountList: [[String: Any]] = [[String: Any]]()
                    let accountDict = ["type": account.type, "value": account.id]
                    accountList.append(accountDict)
                    
                    let params = [
                        APIKeys.SignUp.keyPassword          : userProfile.password ?? "",
                        APIKeys.SignUp.keyRegisterKey       : keys.publicKey,
                        APIKeys.SignUp.keySalt              : keys.salt,
                        APIKeys.SignUp.keyAccountId         : accountList,
                        APIKeys.SignUp.keyInviteCode        : userProfile.inviteCode ??  ""
                        ] as [String : Any]
                    
                    self.postUrl(endpoint, params: params, headers: headers) { (response, error) in
                        
                        // Hide Loading View
                        self.hideProgressHUD()
                        
                        if let error = error {
                            self.showErrorMessage(error.localizedDescription)
                            self.userSignUpFailed!()
                        } else if let response = response {
                            
                            if let accounts = response[APIKeys.Login.keyUpdateAccounts] as? [String] {
                                
                                if let token = response[APIKeys.Login.keyAuthToken] as? String {
                                    UserAuth.setUserToken(token)
                                }
                                
                                UserAuth.setIsChaseAccount(true)
                                
                                if let accountName = response[APIKeys.SignUp.keyAccountName] as? String {
                                    let updateAccount = AccountID(type: accountName, id: account.id)
                                    userProfile.accounts = [updateAccount]
                                }
                                
                                for accountId in accounts {
                                    let updateAccount = AccountID(type: accountId, id: "")
                                    userProfile.accounts.append(updateAccount)
                                }
                                
                                userProfile.saveProfileToUserDefault()
                                
                                KeychainManager().makeEncryptionKey(userProfile.password ?? "")
                                KeychainManager().saveDataToKeychainWith(keys.privateKey, key: Constant.Keys.keyPrivate)
                                KeychainManager().saveDataToKeychainWith(keys.salt, key: Constant.Keys.keySalt)
                                KeychainManager().saveDataToKeychainWith(userProfile.password ?? "", key: Constant.Keys.keyPassword)
                                
                                self.userSignUpSuccess!([APIKeys.Login.keyUpdateAccounts: accounts])
                            } else {
                                self.showErrorMessage(Messages.SignUp.msgSignUpFailed)
                                self.userSignUpFailed!()
                            }
                        } else {
                            self.showErrorMessage(Messages.SignUp.msgSignUpFailed)
                            self.userSignUpFailed!()
                        }
                    }
                }
            }
        }
    }
    
    func updateUser(_ account: AccountID) {
        
        if let connection = AppManager.sharedInstance.reachability?.connection, connection == .none {
            self.showErrorMessage("Connection Failed. Try again later")
            return
        }
        
        // Show Loading View
        self.showProgressHUD()
        
        let endpoint = URLBuilder.urlUpdateUser
        let headers = [
            APIKeys.Header.keyContentType           : "application/json",
            APIKeys.Header.keyAuthorization         : "Bearer \(UserAuth.token)"
        ]
        
        let accountDict = ["type": account.type, "value": account.id]
        
        let params = [
            APIKeys.Login.keyUpdateAccounts         : [accountDict]
        ] as [String : Any]
        
        self.putUrl(endpoint, params: params, headers: headers) { (response, error) in
            
            // Hide Loading View
            self.hideProgressHUD()
            
            if let error = error {
                self.showErrorMessage(error.localizedDescription)
                self.userUpdateInfoFailed!()
            } else if let response = response {
                if let message = response["message"] as? String {
                    self.showErrorMessage(message)
                    self.userUpdateInfoFailed!()
                } else {
                    UserPreference.currentUser.accounts.append(account)
                    UserPreference.currentUser.saveProfileToUserDefault()
                    self.userUpdateInfoSuccess!(response)
                }
            } else {
                self.showErrorMessage(Messages.Account.msgAddAccountFailed)
                self.userUpdateInfoFailed!()
            }
        }
    }
    
    func confirmUser(_ account: AccountID) {
        
        if let connection = AppManager.sharedInstance.reachability?.connection, connection == .none {
            self.showErrorMessage("Connection Failed. Try again later")
            return
        }
        
        // Show Loading View
        self.showProgressHUD()
        
        let endpoint = URLBuilder.urlConfirmAccount
        let headers = [
            APIKeys.Header.keyContentType           : "application/json",
            APIKeys.Header.keyAuthorization         : "Bearer \(UserAuth.token)"
        ]
        
        let params = [
            APIKeys.SignUp.keyConfirmAccount         : account.id
            ] as [String : Any]
        
        self.postUrl(endpoint, params: params, headers: headers) { (response, error) in
            
            // Hide Loading View
            self.hideProgressHUD()
            
            if let error = error {
                self.showErrorMessage(error.localizedDescription)
                self.userUpdateInfoFailed!()
            } else if let response = response {
                if let status = response["status"] as? String, status.lowercased() == "success" {
                    UserPreference.currentUser.accounts = UserPreference.currentUser.accounts.reduce(into: [], { (result, accountId) in
                        if account.type == accountId.type && accountId.id == "" {
                            result.append(account)
                        } else {
                            result.append(accountId)
                        }
                    })
                    
                    let isNotExisting = UserPreference.currentUser.accounts.filter({ (accountId) -> Bool in
                        return accountId.id == account.id && account.type == accountId.type
                    }).count == 0
                    
                    if isNotExisting {
                        UserPreference.currentUser.accounts.append(account)
                    }
                    
                    UserPreference.currentUser.saveProfileToUserDefault()
                    
                    self.userConfirmSuccess!(account.id)
                } else {
                    self.showErrorMessage(Messages.Account.msgConfirmAccountFailed)
                    self.userConfirmFailed!()
                }
            } else {
                self.showErrorMessage(Messages.Account.msgConfirmAccountFailed)
                self.userConfirmFailed!()
            }
        }
    }
}
