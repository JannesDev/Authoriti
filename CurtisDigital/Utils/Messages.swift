//
//  Messages.swift
//  CurtisDigital
//
//  Created by Jannes on 11/15/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit

struct Messages {
    struct Login {
        static let msgSignInSuccess         = "Log In Successfully."
        static let msgSignInFailed          = "Log In Failed. Try Again Later."
        static let msgSignInFillOut         = "Please fill in all fields."
        static let msgSignInEmailFormat     = "Invalid Email Format."
    }
    
    struct SignUp {
        static let msgSignUpSuccess         = "Sign Up Successfully."
        static let msgSignUpFailed          = "Sign Up Failed. Try Again Later."
        static let msgInvalideCode          = "Invalid Code."
        static let msgSignUpFillOut         = "Please fill in all fields."
        static let msgSignUpEmailFormat     = "Invalid Email Format."
        static let msgConfirmPassword       = "Password confirmation failed."
    }
    
    struct Account {
        static let msgAddAccountSuccess     = "Add Account Successfully"
        static let msgAddAccountFailed      = "Failed to add new account. Try again later."
        static let msgConfirmAccountFailed      = "Failed to confirm your account number. Try again later."
    }
    
    struct Location {
        static let msgDisabledService       = "Location Sevice are disabled"
        static let msgDisableDescription    = "Please turn on your GPS to sever you better"
    }
}
