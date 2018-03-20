//
//  Schemas.swift
//  CurtisDigital
//
//  Created by mobilestar on 11/28/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit

enum PickerOptionType: String {
    case accountId      = "accountId"
    case time           = "time"
    case industry       = "industry"
    case location       = "location_state"
    case country        = "location_country"
    case geo            = "geo"
    case requestor      = "requestor"
    case dataType       = "data_type"
    
    func getTitle() -> String {
        switch self {
        case .accountId:
            return Constant.CreatePasscode.AccountID
        case .time:
            return Constant.CreatePasscode.Time
        case .industry:
            return Constant.CreatePasscode.Industry
        case .location:
            return Constant.CreatePasscode.Location
        case .country:
            return Constant.CreatePasscode.Country
        case .geo:
            return Constant.CreatePasscode.Location
        case .requestor:
            return Constant.CreatePasscode.Requestor
        case .dataType:
            return Constant.CreatePasscode.DataType
        }
    }
    
    public func getHeaderTitle() -> String {
        switch self {
        case .accountId:
            return "Please Select A Wallet ID"
        case .time:
            return "Pick a expiry time"
        case .industry:
            return "Pick an Industry"
        case .location:
            return "Pick a Location"
        default:
            return ""
        }
    }
}

struct DetailOptions {
    var title: String
    var value: String
    
    func getDictionaryValue() -> [String: Any] {
        return ["title": title, "value": value]
    }
}

class PasscodeOptions: NSObject {
    var bytes: Int = 0
    var title: String = ""
    var label: String = ""
    var picker: PickerOptionType = .accountId
    var values: [DetailOptions] = [DetailOptions]()
    
    override init() {
        super.init()
    }
    
    init(_ dict: [String: Any]) {
        super.init()
        
        self.bytes = dict["bytes"] as? Int ?? 0
        self.title = dict["title"] as? String ?? ""
        self.label = dict["label"] as? String ?? ""
        
        if let strPicker = dict["picker"] as? String, let pickerType = PickerOptionType(rawValue: strPicker) {
            self.picker = pickerType
        }
        
        if let details = dict["values"] as? [[String: Any]] {
            for value in details {
                if let title = value["title"] as? String, let action = value["value"] as? String {
                    let detail = DetailOptions(title: title, value: action)
                    self.values.append(detail)
                }
            }
        }
    }
    
    func getDictionaryValue() -> [String: Any] {
        var dictionary = [String: Any]()
        
        dictionary["bytes"] = self.bytes
        dictionary["title"] = self.title
        dictionary["picker"] = self.picker.rawValue
        
        var valueInfos = [[String: Any]]()
        for value in values {
            let valueInfo = ["title": value.title, "value": value.value]
            valueInfos.append(valueInfo)
        }
        
        dictionary["values"] = valueInfos
        
        return dictionary
    }
}



class Schema: NSObject {
    var index: Int = 0
    var options: [PasscodeOptions] = [PasscodeOptions]()
    
    init(_ index: Int, options: [[String: Any]]) {
        super.init()
        
        self.index = index
        
        for option in options {
            let passcodeOption = PasscodeOptions(option)
            self.options.append(passcodeOption)
        }
    }
    
    func getDictionaryValue() -> [[String: Any]] {
        
        var pickerOptions = [[String: Any]]()
        for option in options {
            pickerOptions.append(option.getDictionaryValue())
        }
        
        return pickerOptions
    }
}
