//
//  AppManager.swift
//  CurtisDigital
//
//  Created by Jannes on 11/15/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import Reachability

class AppManager: NSObject {
    
    let ecDsa = EcDSA()
    static let sharedInstance = AppManager()
    
    var schemas: [Schema] = [Schema]()
    var purposes: [Purpose] = [Purpose]()
    var datatypes: [DataType] = [DataType]()
    
    let reachability = Reachability()
    
    var calendar: Calendar {
        get {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(secondsFromGMT: 0)!
            return calendar
        }
    }
    
    override init() {
        super.init()
        
        //declare this property where it won't go out of scope relative to your listener
        
        reachability?.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability?.whenUnreachable = { _ in
            print("Not reachable")
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    deinit {
        reachability?.stopNotifier()
    }
    
    
    func defaultOptionsFromUserDefault(_ pickerOption: PickerOptionType, purpose: String) -> Any? {
        let userDefault = UserDefaults.standard
        var defaultDict = userDefault.value(forKey: purpose) as? [String: Any] ?? [String:Any]()
        
        switch pickerOption {
        case .accountId:
            return UserPreference.currentUser.accounts.filter({ (account) -> Bool in
                if let id = defaultDict[pickerOption.getTitle()] as? String {
                    return account.id == id
                }
                
//                if let id = userDefault.value(forKey: pickerOption.getTitle()) as? String {
//                    return account.id == id
//                }
                
                return false
            }).first
        case .time:
            return defaultDict[pickerOption.getTitle()] as? [String: Any?]
//            return userDefault.value(forKey: pickerOption.getTitle()) as? [String: Any?]
            
        case .dataType:
            
            var detailOptions: [DetailOptions] = [DetailOptions]()
            if let dict = defaultDict[pickerOption.getTitle()] as? [[String: Any]] {
                for detailInfo in dict {
                    let option = DetailOptions(title: detailInfo["title"] as? String ?? "", value: detailInfo["value"] as? String ?? "")
                    detailOptions.append(option)
                }
            }
            
//            if let dict = userDefault.value(forKey: pickerOption.getTitle()) as? [[String: Any]] {
//                for detailInfo in dict {
//                    let option = DetailOptions(title: detailInfo["title"] as? String ?? "", value: detailInfo["value"] as? String ?? "")
//                    detailOptions.append(option)
//                }
//            }
            
            return detailOptions
        default:
            if let dict = defaultDict[pickerOption.getTitle()] as? [String: Any] {
                return DetailOptions(title: dict["title"] as? String ?? "", value: dict["value"] as? String ?? "")
            }
            
//            if let dict = userDefault.value(forKey: pickerOption.getTitle()) as? [String: Any] {
//                return DetailOptions(title: dict["title"] as? String ?? "", value: dict["value"] as? String ?? "")
//            }
            
            return nil
        }
    }
    
    func saveDefaultOptionsToUserDefault(_ pickerOption: PickerOptionType, detailOption: Any?, accountId: String? = nil, expireTime: ExpireTime? = nil, purpose: String) {
        let userDefault = UserDefaults.standard
        var defaultDict = userDefault.value(forKey: purpose) as? [String: Any] ?? [String:Any]()
        
        switch pickerOption {
        case .accountId:
            defaultDict[pickerOption.getTitle()] = accountId
//            userDefault.set(accountId ?? "", forKey: pickerOption.getTitle())
        case .time:
            defaultDict[pickerOption.getTitle()] = ["title": expireTime?.option.rawValue, "value": expireTime?.duration]
//            userDefault.set(["title": expireTime?.option.rawValue, "value": expireTime?.duration], forKey: pickerOption.getTitle())
        case .dataType:
            if let detailOption = detailOption as? [DetailOptions] {
                var defaultValue: [[String: Any]] = [[String: Any]]()
                for option in detailOption {
                    defaultValue.append(option.getDictionaryValue())
                }
                defaultDict[pickerOption.getTitle()] = defaultValue
//                userDefault.set(defaultValue, forKey: pickerOption.getTitle())
            }
        default:
            if let detailOption = detailOption as? DetailOptions {
                defaultDict[pickerOption.getTitle()] = ["title": detailOption.title, "value": detailOption.value]
//                userDefault.set(["title": detailOption.title, "value": detailOption.value], forKey: pickerOption.getTitle())
            }
        }
        
        userDefault.set(defaultDict, forKey: purpose)
        userDefault.synchronize()
    }
    
    // MARK: Load and Save Schemas
    func saveSchemaToUserDefault(_ schemaInfos: [String: Any]) {
        
        var schemas: [Schema] = [Schema]()
        var dataTypes: [DataType] = [DataType]()
        
        if let schemaDatas = schemaInfos["schema"] as? [String: Any] {
            for (key, value) in schemaDatas {
                if let value = value as? [[String: Any]], let index = Int(key) {
                    let schema = Schema(index, options: value)
                    schemas.append(schema)
                }
            }
        }
        
        if let dataTypeInfos = schemaInfos["data_type"] as? [String: Any] {
            for (key, value) in dataTypeInfos {
                if let value = value as? [[String: Any]] {
                    let dataType = DataType(key, options: value)
                    dataTypes.append(dataType)
                }
            }
        }
        
        AppManager.sharedInstance.datatypes = dataTypes
        AppManager.sharedInstance.schemas = schemas
        
        let schemaData = NSKeyedArchiver.archivedData(withRootObject: schemaInfos)
        UserDefaults.standard.set(schemaData, forKey: Constant.Keys.keySchemas)
        UserDefaults.standard.synchronize()
    }
    
    func loadSchemaFromUserDefault() {
        guard let schemaData = UserDefaults.standard.value(forKey: Constant.Keys.keySchemas) as? Data else {
            return
        }
        
        let schemaInfos = NSKeyedUnarchiver.unarchiveObject(with: schemaData) as! [String: Any]
        
        var schemas: [Schema] = [Schema]()
        var dataTypes: [DataType] = [DataType]()
        
        if let schemaDatas = schemaInfos["schema"] as? [String: Any] {
            for (key, value) in schemaDatas {
                if let value = value as? [[String: Any]], let index = Int(key) {
                    let schema = Schema(index, options: value)
                    schemas.append(schema)
                }
            }
        }
        
        if let dataTypeInfos = schemaInfos["data_type"] as? [String: Any] {
            for (key, value) in dataTypeInfos {
                if let value = value as? [[String: Any]] {
                    let dataType = DataType(key, options: value)
                    dataTypes.append(dataType)
                }
            }
        }
        
        AppManager.sharedInstance.datatypes = dataTypes
        AppManager.sharedInstance.schemas = schemas
    }
    
    func deleteSchemaFromUserDefault() {
        guard let _ = UserDefaults.standard.value(forKey: Constant.Keys.keySchemas) as? Data else {
            return
        }
        
        UserDefaults.standard.removeObject(forKey: Constant.Keys.keySchemas)
        UserDefaults.standard.synchronize()
        
        self.schemas = [Schema]()
        self.datatypes = [DataType]()
    }
    
    func savePurposeToUserDefault(_ purposeInfos: [[String: Any]]) {
        
        var purposes: [Purpose] = [Purpose]()
        
        for value in purposeInfos {
            let purpose = Purpose(value)
            purposes.append(purpose)
        }
        
        self.purposes = purposes
        
        let schemaData = NSKeyedArchiver.archivedData(withRootObject: purposeInfos)
        UserDefaults.standard.set(schemaData, forKey: Constant.Keys.keyPurpose)
        UserDefaults.standard.synchronize()
    }
    
    func loadPurposeFromUserDefault() {
        guard let purposeData = UserDefaults.standard.value(forKey: Constant.Keys.keyPurpose) as? Data else {
            return
        }
        
        let purposeInfo = NSKeyedUnarchiver.unarchiveObject(with: purposeData) as! [[String: Any]]
        
        var purposes: [Purpose] = [Purpose]()
        
        for value in purposeInfo {
            let purpose = Purpose(value)
            purposes.append(purpose)
        }
        
        self.purposes = purposes
    }
    
    func deletePurposeFromUserDefault() {
        guard let _ = UserDefaults.standard.value(forKey: Constant.Keys.keyPurpose) as? Data else {
            return
        }
        
        UserDefaults.standard.removeObject(forKey: Constant.Keys.keyPurpose)
        UserDefaults.standard.synchronize()
        
        self.purposes = [Purpose]()
    }
    
    func removeAllDefaultOptions() {
        let userDefault = UserDefaults.standard
        
        for purpose in self.purposes {
            userDefault.removeObject(forKey: purpose.title ?? "")
        }
//        userDefault.removeObject(forKey: PickerOptionType.time.getTitle())
//        userDefault.removeObject(forKey: PickerOptionType.industry.getTitle())
//        userDefault.removeObject(forKey: PickerOptionType.location.getTitle())
//        userDefault.removeObject(forKey: PickerOptionType.country.getTitle())
        userDefault.synchronize()
    }
    
    func generateKeyPair(_ password: String, salt: String? = nil) -> (salt: String, publicKey: String, privateKey: String) {
        let keypairData = ecDsa.generate(password: password, salt: salt)
        
        let salt = keypairData.salt
        let publicKey = keypairData.publicKey
        let privateKey = keypairData.privateKey
        
        print(salt, publicKey, privateKey)
                
        return (salt, publicKey, privateKey)
    }
    
    func generatePasscode(_ payload: String) -> String? {
        let keychain = KeychainManager()
        if let privateKeyData = keychain.getDataFromKeychain(Constant.Keys.keyPrivate), let privateKey = String.init(data: privateKeyData, encoding: .utf8) {
            print("payload", payload);
            let passcode = ecDsa.sign(payload: payload, privateKey: privateKey)
            print("PC", passcode);
            return passcode
        }
        
        return nil
    }
}
