//
//  AppUtility.swift
//  CurtisDigital
//
//  Created by Brian on 2017-12-06.
//  Copyright © 2017 Mark. All rights reserved.
//

import Foundation
import SwiftValidator

struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
}


public class EqualRule: Rule {
    /// parameter confirmField: field to which original text field will be compared to.
    private let equalString: String
    /// parameter message: String of error message.
    private var message : String
    
    /**
     Initializes a `ConfirmationRule` object to validate the text of a field that should equal the text of another field.
     
     - parameter confirmField: field to which original field will be compared to.
     - parameter message: String of error message.
     - returns: An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public init(equalString: String, message : String = "This value does not match"){
        self.equalString = equalString
        self.message = message
    }
    
    /**
     Used to validate a field.
     
     - parameter value: String to checked for validation.
     - returns: A boolean value. True if validation is successful; False if validation fails.
     */
    public func validate(_ value: String) -> Bool {
        return self.equalString == value
    }
    
    /**
     Displays an error message when text field fails validation.
     
     - returns: String of error message.
     */
    public func errorMessage() -> String {
        return message
    }
}

