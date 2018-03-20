//
//  Vlidatable+Extension.swift
//  CurtisDigital
//
//  Created by mobilestar on 11/30/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import SwiftValidator

extension MDTextField: Validatable {
    public var validationText: String {
        return text ?? ""
    }
}

