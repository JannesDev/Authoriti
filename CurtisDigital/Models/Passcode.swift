//
//  Passcode.swift
//  CurtisDigital
//
//  Created by mobilestar on 11/16/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import BigInt

enum ExpireTimeOption: Int {
    case quarter = 0
    case oneHour
    case fourHour
    case oneDay
    case oneWeek
    case customTime
    case customDateTime
    
    public func getStringValue() -> String {
        switch self {
        case .quarter:
            return "15 Mins"
        case .oneHour:
            return "1 Hour"
        case .fourHour:
            return "4 Hours"
        case .oneDay:
            return "1 Day"
        case .oneWeek:
            return "1 Week"
        case .customTime:
            return "Custom Time"
        case .customDateTime:
            return "Custom Date/Time"
        }
    }
    
    public func getExpireTime() -> ExpireTime {
        switch self {
        case .quarter:
            return ExpireTime(option: .quarter, duration: 15, dateCompoment: .minute)
        case .oneHour:
            return ExpireTime(option: .oneHour, duration: 1, dateCompoment: .hour)
        case .fourHour:
            return ExpireTime(option: .fourHour, duration: 4, dateCompoment: .hour)
        case .oneDay:
            return ExpireTime(option: .oneDay, duration: 1, dateCompoment: .day)
        case .oneWeek:
            return ExpireTime(option: .oneWeek, duration: 7, dateCompoment: .day)
        case .customTime:
            return ExpireTime(option: .customTime, duration: 2, dateCompoment: .hour)
        case .customDateTime:
            return ExpireTime(option: .customDateTime, duration: 2, dateCompoment: .day)
        }
    }
    
    static func count() -> Int {
        return 7
    }
}

struct AccountID {
    public var type: String
    public var id: String
}

struct ExpireTime {
    public var option: ExpireTimeOption
    public var duration: Int
    public var dateCompoment: Calendar.Component
}

class Passcode: NSObject {
    var code: String?
    var selectedAccount: AccountID!
    var expireTime: ExpireTime!
    var purpose: Purpose!
    
    var accountOption: DetailOptions!
    var industryOption: DetailOptions!
    var stateOption: DetailOptions!
    var geoOption: DetailOptions!
    var countryOption: DetailOptions!
    var requestorOption: DetailOptions!
    var dataTypeOption: [DetailOptions] = [DetailOptions]()
    
    override init() {
        super.init()
    }
    
    class func setAsDefault(_ purpose: Purpose) -> Passcode {
        let passcode = Passcode()
        
        passcode.code = nil
        let account = UserPreference.currentUser.accounts.filter({ (account) -> Bool in
            if let id = AppManager.sharedInstance.defaultOptionsFromUserDefault(.accountId, purpose: "account") as? AccountID {
                return id.id == account.id
            }
            
            return false
        }).first
        
        if let account = account {
            passcode.selectedAccount = account
        } else {
            passcode.selectedAccount = UserPreference.currentUser.accounts.first ?? AccountID(type: "", id: "")
        }
        
        if let time = AppManager.sharedInstance.defaultOptionsFromUserDefault(.time, purpose: purpose.title ?? "") as? [String: Any?], let option = time["title"] as? Int, let timeOption = ExpireTimeOption(rawValue: option) {
            switch timeOption {
            case .quarter:
                passcode.expireTime = ExpireTime(option: .quarter, duration: 15, dateCompoment: .minute)
            case .oneHour:
                passcode.expireTime = ExpireTime(option: .oneHour, duration: 1, dateCompoment: .hour)
            case .fourHour:
                passcode.expireTime = ExpireTime(option: .fourHour, duration: 4, dateCompoment: .hour)
            case .oneDay:
                passcode.expireTime = ExpireTime(option: .oneDay, duration: 1, dateCompoment: .day)
            case .oneWeek:
                passcode.expireTime = ExpireTime(option: .oneDay, duration: 7, dateCompoment: .day)
            case .customTime:
                passcode.expireTime = ExpireTime(option: .customTime, duration: time["value"] as? Int ?? 0, dateCompoment: .minute)
            case .customDateTime:
                passcode.expireTime = ExpireTime(option: .customDateTime, duration: time["value"] as? Int ?? 0, dateCompoment: .minute)
            }
        } else {
            passcode.expireTime = ExpireTime(option: .quarter, duration: 15, dateCompoment: .minute)
        }
        
        passcode.purpose = purpose
        
        for option in purpose.getSchema()!.options {
            switch option.picker {
            case .accountId:
                if option.values.count == 0 {
                    passcode.accountOption = DetailOptions(title: "user_selected", value: "1")
                } else {
                    passcode.accountOption = option.values.first
                }
                break
            case .industry:
                if let industry = AppManager.sharedInstance.defaultOptionsFromUserDefault(.industry, purpose: purpose.title ?? "") as? DetailOptions {
                    passcode.industryOption = industry
                } else {
                    passcode.industryOption = option.values.first
                }
                break
            case .country:
                if let country = AppManager.sharedInstance.defaultOptionsFromUserDefault(.country, purpose: purpose.title ?? "") as? DetailOptions {
                    passcode.countryOption = country
                } else if option.values.count == 0 {
                    passcode.countryOption = DetailOptions(title: "United States", value: "1")
                } else {
                    passcode.countryOption = option.values.first
                }
                break
            case .location:
                if let location = AppManager.sharedInstance.defaultOptionsFromUserDefault(.location, purpose: purpose.title ?? "") as? DetailOptions {
                    passcode.stateOption = location
                } else {
                    passcode.stateOption = option.values.first
                }
            case .geo:
                if let location = AppManager.sharedInstance.defaultOptionsFromUserDefault(.geo, purpose: purpose.title ?? "") as? DetailOptions {
                    passcode.geoOption = location
                } else {
                    passcode.geoOption = option.values.first
                }
            case .requestor:
                if let requestor = AppManager.sharedInstance.defaultOptionsFromUserDefault(.requestor, purpose: purpose.title ?? "") as? DetailOptions {
                    passcode.requestorOption = requestor                    
                } else {
                    passcode.requestorOption = option.values.first
                }
                break
            case .dataType:
                if let dataTypeOption = AppManager.sharedInstance.defaultOptionsFromUserDefault(.dataType, purpose: purpose.title ?? "") as? [DetailOptions], dataTypeOption.count > 0 {
                    if let dataType = AppManager.sharedInstance.datatypes.filter({$0.requestor == passcode.requestorOption.value}).first {
                        var isMatch = true
                        for option in dataTypeOption {
                            if !dataType.options.contains(where: {$0.title == option.title}) {
                                isMatch = false
                            }
                        }
                        
                        if isMatch {
                            passcode.dataTypeOption = dataTypeOption
                        } else {
                            passcode.dataTypeOption = (dataType.options.count > 0) ? [dataType.options[0]] : []
                        }
                    }
                } else {
                    if let dataType = AppManager.sharedInstance.datatypes.filter({$0.requestor == passcode.requestorOption.value}).first {
                        if let option = dataType.options.first {
                            passcode.dataTypeOption = [option]
                        }
                    }
                }
                break
            case .time:
                break
            }
        }
        
        if let type = purpose.exceptPickerType {
            switch type {
            case .industry:
                passcode.industryOption = DetailOptions(title: type.getTitle(), value: purpose.value ?? "")
                break
            case .country:
                passcode.countryOption = DetailOptions(title: type.getTitle(), value: purpose.value ?? "")
                break
            case .location:
                passcode.stateOption = DetailOptions(title: type.getTitle(), value: purpose.value ?? "")
                break
            case .requestor:
                passcode.requestorOption = DetailOptions(title: type.getTitle(), value: purpose.value ?? "")
                break
            case .dataType:
                passcode.dataTypeOption = [DetailOptions(title: type.getTitle(), value: purpose.value ?? "")]
                break
            case .geo:
                passcode.geoOption = DetailOptions(title: type.getTitle(), value: purpose.value ?? "")
                break
            case .accountId:
                break
            case .time:
                break
            }
        }
        
        return passcode
    }
    
    func generatePayload() -> String {
        var compoments = AppManager.sharedInstance.calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        compoments.second = 0
        let currentDate = AppManager.sharedInstance.calendar.date(from: compoments)!
        let expoireDate = AppManager.sharedInstance.calendar.date(byAdding: expireTime.dateCompoment, value: expireTime.duration, to: currentDate)
        let expireComponent = AppManager.sharedInstance.calendar.dateComponents([.year, .month, .day, .hour, .minute], from: expoireDate!)
        
        let expire = AppManager.sharedInstance.ecDsa.encodeDate(year: expireComponent.year ?? 0, month: expireComponent.month ?? 0, day: expireComponent.day ?? 0, hour: expireComponent.hour ?? 0, minute: expireComponent.minute ?? 0)
        
        var payload = ""
        
        for option in purpose.getSchema()!.options {
            switch option.picker {
            case .accountId:
                payload = payload + self.accountOption.value
                break
            case .industry:
                // TODO: Set correct industry value
                payload = payload + self.industryOption.value
                break
            case .country:
                payload = payload + self.countryOption.value
                break
            case .location:
                payload = payload + self.stateOption.value
                
            case .time:
                payload = payload + expire
                break
            case .requestor:
                payload = payload + self.requestorOption.value
                print("requestor", payload);
            case .geo:
                payload = EcDSA().encodeGeo(geo: self.geoOption.value, payload: payload)
                print("geo", payload)
                break
            case .dataType:
                var bitmask = ""
                if let dataType = AppManager.sharedInstance.datatypes.filter({$0.requestor == self.requestorOption.value}).first {
                    for option in dataType.options {
                        if let _ = self.dataTypeOption.filter({$0.title == option.title}).first {
                            bitmask = bitmask + "1"
                        } else {
                            bitmask = bitmask + "0"
                        }
                    }
                }
                
                payload = EcDSA().encodeDataTypes(selectedTypes: bitmask, payload: payload)
                print("dataType", payload);
                break
            }
        }
        print("Without account-id", payload);
        return payload
    }
}

