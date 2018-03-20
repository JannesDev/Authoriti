//
//  LogInViewController.swift
//  CurtisDigital
//
//  Created by Jannes on 11/14/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import MaterialComponents
import BiometricAuthentication
import SwiftValidator
import DropDown
import BEMCheckBox

class LogInViewController: BaseViewController {
    
    @IBOutlet weak var txtAccount: MDCTextField!
    @IBOutlet weak var txtPasswd: MDCTextField!
    @IBOutlet weak var viewCheckDefault: UIView!
    @IBOutlet weak var btnDefault: BEMCheckBox!
    @IBOutlet weak var btnSignin: MDCRaisedButton!
    @IBOutlet weak var btnSignUp: MDCRaisedButton!
    @IBOutlet weak var btnResetPW: UIButton!
    
    let accountDropDown = DropDown()
    var txtAccountController: MDCTextInputControllerDefault?
    var txtPasswdController: MDCTextInputControllerDefault?

    var allTextFieldControllers = [MDCTextInputControllerDefault]()
    
    var loginService: LogInService?
    
    let formValidator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideNavigationBar = true
        self.loginService = self
        
        self.setupValidateRules()
        self.setupViews()
        
        if BioMetricAuthenticator.canAuthenticate() && UserAuth.isTouchId {
            self.signInWithFingerPrint(nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.reloadViews()
    }
    
    func setupViews() {
        txtAccount.inputView            = UIView()
        txtAccount.trailingView         = UIImageView.init(image: #imageLiteral(resourceName: "arrow-drop-down"))
        txtAccount.trailingViewMode     = .always
        txtAccount.font                 = Fonts.textField.textFont
        txtAccountController                                    = MDCTextInputControllerDefault(textInput: txtAccount)
        txtAccountController!.placeholderText                   = "Select your account"
        txtAccountController!.activeColor                       = Colors.appColor
        txtAccountController!.inlinePlaceholderFont             = Fonts.textField.placeholderFont
        txtAccountController!.leadingUnderlineLabelFont         = Fonts.textField.errorFont
        allTextFieldControllers.append(txtAccountController!)
        
        accountDropDown.anchorView          = txtAccount
        accountDropDown.textFont            = Fonts.textField.textFont!
        accountDropDown.dismissMode         = .onTap
        accountDropDown.direction           = .bottom
        accountDropDown.selectionAction     = { [unowned self] (index, item) in
            self.txtAccount.text = item
            self.validateField(self.txtAccount)
            
            if let defaultAccount = AppManager.sharedInstance.defaultOptionsFromUserDefault(.accountId, purpose: "account") as? AccountID, item == defaultAccount.type {
               self.btnDefault.setOn(true, animated: false)
            } else {
                self.btnDefault.setOn(false, animated: false)
            }
            
            self.viewCheckDefault.isHidden = false
        }
        
        self.btnDefault.onTintColor = Colors.appColor
        self.btnDefault.onCheckColor = UIColor.white
        self.btnDefault.onFillColor = Colors.appColor
        self.btnDefault.boxType = .square
        
        txtPasswd.font                                      = Fonts.textField.textFont
        txtPasswdController                                 = MDCTextInputControllerDefault(textInput: txtPasswd)
        txtPasswdController!.placeholderText                = "Enter your password"
        txtPasswdController!.activeColor                    = Colors.appColor
        txtPasswdController!.inlinePlaceholderFont          = Fonts.textField.placeholderFont
        txtPasswdController!.leadingUnderlineLabelFont      = Fonts.textField.errorFont
        allTextFieldControllers.append(txtPasswdController!)
    }
    
    func reloadViews() {
        accountDropDown.dataSource = UserPreference.currentUser.accounts.reduce(into: [], { (accountIds, AccountID) in
            if AccountID.id != "" {
                accountIds.append(AccountID.type)
            }
        })
        
        accountDropDown.reloadAllComponents()
        
        if let defaultAccount = AppManager.sharedInstance.defaultOptionsFromUserDefault(.accountId, purpose: "account") as? AccountID {
            self.txtAccount.text = defaultAccount.type
            self.validateField(self.txtAccount)
            
            self.btnDefault.setOn(true, animated: false)
            
            self.viewCheckDefault.isHidden = false
        } else if UserPreference.currentUser.accounts.count < 0 {
            self.viewCheckDefault.isHidden = true
        } else if let firstAccount = UserPreference.currentUser.accounts.first {
            self.txtAccount.text = firstAccount.type
            self.validateField(self.txtAccount)
            
            self.btnDefault.setOn(false, animated: false)
            
            self.viewCheckDefault.isHidden = false
        }
    }
    
    func setupValidateRules() {
        
        formValidator.styleTransformers(success:{ (validationRule) -> Void in
            print("here")
            // clear error label
            if let textField = validationRule.field as? MDCTextField {
                self.allTextFieldControllers[textField.tag].setErrorText(nil, errorAccessibilityValue: nil)
            }
        }, error:{ (validationError) -> Void in
            print("error")
            if let textField = validationError.field as? UITextField {
                self.allTextFieldControllers[textField.tag].setErrorText(validationError.errorMessage, errorAccessibilityValue: nil)
            }
        })
        
        formValidator.registerField(txtAccount, rules: [RequiredRule(message: "Choose your account.")])
        formValidator.registerField(txtPasswd, rules: [RequiredRule()])
    }
    
    func validateField(_ textField: MDCTextField) {
        formValidator.validateField(textField) { validationError in
            self.allTextFieldControllers[textField.tag].setErrorText(validationError?.errorMessage, errorAccessibilityValue: nil)
        }
    }
    
    func proceedSignin() {
        self.view.endEditing(true)
        
        let accounts = UserPreference.currentUser.accounts.filter { (accountID) -> Bool in
            return accountID.type == txtAccount.text ?? ""
        }
        
        if let account = accounts.first {
            self.loginService?.loginWith(account, password: txtPasswd.text ?? "", isSelected: self.btnDefault.on)
        }
    }
    
    private func goMyPasscodes() {
        UserAuth.setIsLoggedIn(true)
        UserAuth.setLastTime()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navController = storyboard.instantiateViewController(withIdentifier: "MainNavController")
        
        if let window = UIApplication.shared.delegate?.window {
            UIView.transition(with: window!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                let oldState: Bool = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(true)
                window?.rootViewController = navController
                UIView.setAnimationsEnabled(oldState)
            }, completion: nil)
        }
    }
    
    // MARK: @IBActions
    @IBAction func onTextFieldChanged(_ sender: MDCTextField) {
        self.validateField(sender)
    }
    
    @IBAction func signInWithFingerPrint(_ sender: Any?) {
        print(BioMetricAuthenticator.canAuthenticate())
        
        let keyChain = KeychainManager()
        if let _ = keyChain.getDataFromKeychain(Constant.Keys.keyPassword), let _ = keyChain.getDataFromKeychain(Constant.Keys.keyPrivate), UserAuth.token != "" {
            BioMetricAuthenticator.authenticateWithBioMetrics(reason: "", success: {
                // successful
                self.showToast("Authentication successful!")
                self.goMyPasscodes()
            }, failure: { [weak self] (error) in
                // do nothing on canceled
                if error == .canceledByUser || error == .canceledBySystem {
                    self?.txtPasswd.becomeFirstResponder()
                    return
                } else if error == .fallback {
                    self?.txtPasswd.becomeFirstResponder()
                } else if error == .biometryNotEnrolled {
                    return
                } else if error == .biometryLockedout {
                    BioMetricAuthenticator.authenticateWithPasscode(reason: error.message(), success: {
                        // passcode authentication success
                        self?.showToast("Authentication successful!")
                        self?.goMyPasscodes()
                    }) { (error) in
                        print(error.message())
                    }
                } else if error == .failed {
                    self?.showErrorMessage(error.message())
                }
            })
        }
    }
    
    @IBAction func onSigninPressed(_ sender: MDCRaisedButton) {
        self.view.endEditing(true)
        // Touch ID authentiation
        formValidator.validate(self)
    }
    
    @IBAction func goSignUpScreen(_ sender: Any?) {
        self.view.endEditing(true)
        
        self.performSegue(withIdentifier: "goSignUpSegue", sender: nil)
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        self.view.endEditing(true)
        
        self.performSegue(withIdentifier: "ResetPasswordSegue", sender: nil)
    }
    
    // MARK: Touch ID Authentication
    func authenticateUser() {
        self.proceedSignin()
    }
    
}

extension LogInViewController: ValidationDelegate {
    func validationSuccessful() {
        self.authenticateUser()
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (field, error) in errors {
            if let field = field as? UITextField {
                allTextFieldControllers[field.tag].setErrorText(error.errorMessage, errorAccessibilityValue: nil)
            }
        }
    }
}

extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtAccount{
            accountDropDown.show()
            return false
        } else {
            return true
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtAccount {
            txtPasswd.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}

extension LogInViewController: LogInService {
    
    func userLoginSuccess() {
        self.goMyPasscodes()
    }
    
    func userLoginFailed() {
        
    }
}
