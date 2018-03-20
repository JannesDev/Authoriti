//
//  KeychainManager.swift
//  CurtisDigital
//
//  Created by mobilestar on 12/5/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import KeychainSwift
import RNCryptor

class KeychainManager: NSObject {

    var keychain: KeychainSwift!
    
    override init() {
        super.init()
        
        self.keychain = KeychainSwift()
    }
    
    func makeEncryptionKey(_ password: String) {
        if let _ = keychain.get(Constant.Keys.keyEncryption) {
            keychain.delete(Constant.Keys.keyEncryption)
            return
        }
        
        let salt = Util.generateRandomBytes(len: 10)!
        let incryptedKey = RNCryptor.FormatV3.makeKey(forPassword: password, withSalt: salt)
        keychain.set(incryptedKey, forKey: Constant.Keys.keyEncryption)
    }
    
    func saveDataToKeychainWith(_ value: String, key: String) {
        if let encryptionKey = keychain.getData(Constant.Keys.keyEncryption) {
            let strEncryptionKey = encryptionKey.bytes.toHexString()
            let encryptedValue = RNCryptor.encrypt(data: value.data(using: .utf8)!, withPassword: strEncryptionKey)
            keychain.set(encryptedValue, forKey: key)//, withAccess: .accessibleWhenPasscodeSetThisDeviceOnly)
        }
    }
    
    func saveDataToKeychainWith(_ value: Data, key: String) {
        if let encryptionKey = keychain.getData(Constant.Keys.keyEncryption) {
            let strEncryptionKey = encryptionKey.bytes.toHexString()
            let encryptedValue = RNCryptor.encrypt(data: value, withPassword: strEncryptionKey)
            keychain.set(encryptedValue, forKey: key)//, withAccess: .accessibleWhenPasscodeSetThisDeviceOnly)
        }
    }
    
    func getDataFromKeychain(_ key: String) -> Data? {
        if let encryptionKey = keychain.getData(Constant.Keys.keyEncryption) {
            let strEncryptionKey = encryptionKey.bytes.toHexString()
            if let encryptedValue = keychain.getData(key) {
                do {
                    let value = try RNCryptor.decrypt(data: encryptedValue, withPassword: strEncryptionKey)
                    return value
                } catch (let error) {
                    print(error.localizedDescription)
                }
            }
        }
        
        return nil
    }
    
    func clearAllData() {
        keychain.delete(Constant.Keys.keyPrivate)
        keychain.delete(Constant.Keys.keyPassword)
        keychain.delete(Constant.Keys.keySalt)
    }
}
