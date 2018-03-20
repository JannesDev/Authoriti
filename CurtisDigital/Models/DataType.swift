//
//  DataType.swift
//  CurtisDigital
//
//  Created by mobilestar on 2/27/18.
//  Copyright © 2018 Mark. All rights reserved.
//

import UIKit

class DataType: NSObject {
 
    var requestor: String!
    var options: [DetailOptions] = [DetailOptions]()
    
    init(_ index: String, options: [[String: Any]]) {
        super.init()
        
        self.requestor = index
        
        for option in options {
            
            let passcodeOption = DetailOptions(title: option["title"] as? String ?? "", value: option["value"] as? String ?? "")
            self.options.append(passcodeOption)
        }
    }
}
