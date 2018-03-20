//
//  Constant.swift
//  CurtisDigital
//
//  Created by Jannes on 11/14/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit

struct AppErrorInfo {
    static let Domain                           = "https://ctm-authoriti.crts.io" // error domain
    static let ErrorDescriptionKey              = "description" // human-readable description
    static let ErrorKey                         = "error" // underlying error object
}

struct Constant {
    struct Keys {
        static let keyAuthToken                 = "KEYAUTHTOKEN"
        static let keyUserId                    = "KEYUSERID"
        static let keyIsChaseAccount            = "KEYISCHASEACCOUNT"
        static let keyActiveLastTime            = "KEYACTIVELASTTIME"
        static let keyIsLoggedIn                = "KEYISLOGGEDIN"
        static let keyIsTouchId                 = "KEYISTOUCHID"
        static let keyUserProfile               = "KEYUSERPROFILE"
        static let keyDefaultAccount            = "KEYDEFAULTACCOUNT"
        static let keyPrivate                   = "PRIVATEKEY.com.curtisdigital.authoriti"
        static let keyPassword                  = "KEYPASSWORD.com.curtisdigital.authoriti"
        static let keySalt                      = "KEYSALT.com.curtisdigital.authoriti"
        static let keyEncryption                = "KEYENCRYPTION.com.curtisdigital.authoriti"
        static let keySchemas                   = "KEYSCHEMA"
        static let keyPurpose                   = "KEYPURPOSE"
        static let AcuantLicenseKey             = "FAD9B2F0E7F1"
    }
    
    struct CreatePasscode {
        static let AccountID                    = "Account"
        static let Time                         = "Time"
        static let Industry                     = "Industry"
        static let Location                     = "Location"
        static let Country                      = "Country"
        static let Requestor                    = "Requestor"
        static let DataType                     = "Data-Type"
    }
}


// MARK: - App Colors
struct Colors {
    static let navigationBarTintColor           = UIColor(hex: "3eb0df")
    static let appColor                         = UIColor(hex: "3eb0df")
    static let backgroundViewColor              = UIColor(hex: "f0f3f7")
    static let warningColor                     = UIColor(hex: "FFC55A")
    
    struct LogIn {
        static let signInButtonColor            = UIColor(hex: "0979c3")
    }
    
    struct CreatePasscode {
        static let generateButtonColor          = UIColor(hex: "19b9e4")
        static let titleLabelColor              = UIColor(hex: "465156")
        static let textColor                    = UIColor(hex: "9d9d9d")
        static let saveButtonColor              = UIColor(hex: "21b01b")
    }
    
    struct PasscodeGeneration {
        static let qrCodeColor                  = UIColor(hex: "465156")
        static let contentShadowColor           = UIColor(hex: "0e2c2e")
    }
}

struct Fonts {
    struct textField {
        static let textFont                     = UIFont.init(name: "Oswald-Regular", size: 15)
        static let buttonFont                   = UIFont.init(name: "Oswald-Bold", size: 18)
        static let placeholderFont              = UIFont.init(name: "Oswald-Regular", size: 13)
        static let errorFont                    = UIFont.init(name: "Oswald-Regular", size: 10)
    }
}
struct APIKeys {
    struct Header {
        static let keyContentType               = "Content-Type"
        static let keyAuthorization             = "Authorization"
    }
    
    struct Login {
        static let keyUser                      = "user"
        static let keyPassword                  = "password"
        static let keyAuthToken                 = "token"
        static let keyUpdateAccounts            = "accounts"
        static let keyEmail                     = "email"
    }
    
    struct SignUp {
        static let keyPassword                  = "password"
        static let keyName                      = "name"
        static let keyRegisterKey               = "key"
        static let keyAccountId                 = "account"
        static let keySalt                      = "salt"
        static let keyDeviceTime                = "deviceTime"
        static let keyAccounts                  = "accounts"
        static let keyInviteCode                = "code"
        static let keyConfirmAccount            = "accountId"
        static let keyAccountName               = "accountName"
    }
    
    struct Log {
        static let keyToken                     = "TOKEN"
        static let keyEvents                    = "events"
        static let keyEvent                     = "event"
        static let keyTime                      = "time"
        static let keyMetaData                  = "metadata"
        static let keyLog                       = "log"
    }
}

// MARK: - Web Service /////////////////////////////////////////////////////////
//
struct NetworkHosts
{
//    static let ServerURL = "https://ctm-authoriti.crts.io"
    static let ServerURL = "https://validate.authroriti.crts.io"
//    static let ServerURL = "https://authoriti-qa.crts.io"
}

struct URLBuilder {
    static let EnvironmentURL: String = "/api/v1"

    // MARK: - URL format
    static var BaseURL: String { get {
        return DomainName + EnvironmentURL
        }
    }
    
    static var DomainName: String { get {
        return NetworkHosts.ServerURL
        }
    }

    // MARK: - User URLs
    static var urlLogin: String { get {
        return BaseURL + "/auth/login"
        }
    }
    
    static var urlLogout: String { get {
        return BaseURL + "/auth/logout"
        }
    }
    
    static var urlWipe: String { get {
        return BaseURL + "/users"
        }
    }
    
    static var urlInviteCode: String { get {
        return BaseURL + "/invite"
        }
    }
    
    static var urlSignUp: String { get {
            return BaseURL + "/users"
        }
    }
    
    static var urlUpdateUser: String { get {
        return BaseURL + "/users"
        }
    }
    
    static var urlConfirmAccount: String { get {
        return BaseURL + "/users/confirm"
        }
    }
    
    static var urlGetSchema: String { get {
        return BaseURL + "/schema"
        }
    }
    
    static var urlGetPurpose: String { get {
        return BaseURL + "/purpose"
        }
    }
    
    static var urlLog: String { get {
        return BaseURL + "/log"
        }
    }
    
    static var urlHelper: String { get {
            return DomainName + "/help"
        }
    }
}
