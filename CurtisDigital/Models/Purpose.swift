//
//  Purpose.swift
//  CurtisDigital
//
//  Created by mobilestar on 2/27/18.
//  Copyright © 2018 Mark. All rights reserved.
//

import UIKit

class Purpose: NSObject {

    static let defaultPurpose = "DefaultPurpose"
    
    var title: String?
    var numSchema: Int?
    var picker: String?
    var value: String?

    var exceptPickerType: PickerOptionType!
    
    override init() {
        super.init()
    }
    
    init(_ dict: [String: Any]) {
        super.init()
        
        self.title = dict["label"] as? String
        self.numSchema = dict["schema"] as? Int
        self.picker = dict["picker"] as? String
        self.value = dict["value"] as? String
        
        if let picker = self.picker, let type = PickerOptionType(rawValue: picker) {
            self.exceptPickerType = type
        }
    }
    
    func savePurposeAsDefault() {
        let userDefault = UserDefaults.standard
        userDefault.setValue(self.title, forKey: Purpose.defaultPurpose)
    }
    
    func getSchema() -> Schema? {
        if let schema = AppManager.sharedInstance.schemas.filter({$0.index == self.numSchema}).first {
            return schema
        }
        
        return nil
    }
    
    func getPickerCount() -> Int {
        guard let schema = self.getSchema() else {
            return 0
        }
        
        let availablePhisically = schema.options.filter { (option) -> Bool in
            return (option.picker != .country && option.picker != self.exceptPickerType)
        }
        
        return availablePhisically.count
    }
    
    class func getDefaultPurpose() -> String? {
        guard let purpose = UserDefaults.standard.value(forKey: Purpose.defaultPurpose) as? String else {
            return nil
        }
        
        return purpose
    }
}
