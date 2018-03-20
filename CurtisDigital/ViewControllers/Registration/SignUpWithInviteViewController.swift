//
//  SignUpWithInviteViewController.swift
//  CurtisDigital
//
//  Created by mobilestar on 12/6/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import MaterialComponents
import SwiftValidator
import BiometricAuthentication

class SignUpWithInviteViewController: BaseViewController {

    @IBOutlet weak var txtAccountId: MDCTextField!
    @IBOutlet weak var txtPasswd: MDCTextField!
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var txtAccountIdController: MDCTextInputControllerDefault?,
    txtPasswdController: MDCTextInputControllerDefault?
    
    var allTextFieldControllers = [MDCTextInputControllerDefault]()
    
    let formValidator = Validator()
    
    var customerName: String!
    
    var signUpService: RegistrationService?
    
    var confirmNeededAccounts: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signUpService = self
        
        setupViews()
        setupValidateRules()
        registerKeyboardNotifications()
        addGestureRecognizer()
    }
    
    func setupViews() {
        
        self.headerLabel.text = "\(customerName ?? "") is a partner of Authority. Please enter your \(customerName ?? "") password so we can authorize you."
        
        txtAccountId.font                                   = Fonts.textField.textFont
        txtAccountIdController                              = MDCTextInputControllerDefault(textInput: txtAccountId)
        txtAccountIdController!.placeholderText             = "\((customerName ?? "").uppercased()) IDENTIFIER"
        txtAccountIdController!.activeColor                 = Colors.appColor
        txtAccountIdController!.inlinePlaceholderFont       = Fonts.textField.placeholderFont
        txtAccountIdController!.leadingUnderlineLabelFont   = Fonts.textField.errorFont
        allTextFieldControllers.append(txtAccountIdController!)
        
        txtPasswd.font                                          = Fonts.textField.textFont
        txtPasswdController                                     = MDCTextInputControllerDefault(textInput: txtPasswd)
        txtPasswdController!.placeholderText                    = "PASSWORD"
        txtPasswdController!.activeColor                        = Colors.appColor
        txtPasswdController!.inlinePlaceholderFont              = Fonts.textField.placeholderFont
        txtPasswdController!.leadingUnderlineLabelFont          = Fonts.textField.errorFont
        allTextFieldControllers.append(txtPasswdController!)
    }
    
    func setupValidateRules() {
        
        formValidator.styleTransformers(success:{ (validationRule) -> Void in
            // clear error label
            if let textField = validationRule.field as? MDCTextField {
                self.allTextFieldControllers[textField.tag].setErrorText(nil, errorAccessibilityValue: nil)
            }
        }, error:{ (validationError) -> Void in
            if let textField = validationError.field as? UITextField {
                self.allTextFieldControllers[textField.tag].setErrorText(validationError.errorMessage, errorAccessibilityValue: nil)
            }
        })
        
        formValidator.registerField(txtAccountId, rules: [RequiredRule()])
        formValidator.registerField(txtPasswd, rules: [RequiredRule()])
    }
    
    func proceedSignup() {
        UserPreference.currentUser.password = self.txtPasswd.text
        let account = AccountID(type: "", id: self.txtAccountId.text!)
        
        self.signUpService?.userSignUpWithCustomer(account)
    }
    
    func addGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(tapDidTouch(sender: )))
        self.scrollView.addGestureRecognizer(tapRecognizer)
    }
    
    private func goMyPasscodes() {
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
    
    private func goNext() {
        AppManager.sharedInstance.deleteSchemaFromUserDefault()
        AppManager.sharedInstance.removeAllDefaultOptions()
        
        if self.confirmNeededAccounts.count == 0 {
            UserAuth.setIsLoggedIn(true)
            UserAuth.setLastTime()
            self.goMyPasscodes()
        } else  {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let inputAccountVC = storyboard.instantiateViewController(withIdentifier: "InputAccountViewController") as! InputAccountViewController
            inputAccountVC.isSignUp = true
            self.navigationController?.pushViewController(inputAccountVC, animated: true)
        }
    }
    
    func showEnableTouchId() {
        if !BioMetricAuthenticator.shared.faceIDAvailable() {
            let alertControl = UIAlertController(title: "Please go to Touch ID and Passcode on Device Settings and enroll your fingerprint.", message: nil, preferredStyle: .alert)
            let dontAllow = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let allow = UIAlertAction(title: "Go Setting", style: .default, handler: { (_) in
                let url = URL(string: "App-Prefs:root=TOUCHID_PASSCODE")
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
            })
            
            alertControl.addAction(dontAllow)
            alertControl.addAction(allow)
            
            self.present(alertControl, animated: true, completion: nil)
        } else {
            let alertControl = UIAlertController(title: "Please go to Device Face ID and Passcode on Device Settings and enroll your face.", message: nil, preferredStyle: .alert)
            let dontAllow = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let allow = UIAlertAction(title: "Go Setting", style: .default, handler: { (_) in
                let url = URL(string: "App-Prefs:root=FACEID_PASSCODE")
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
            })
            
            alertControl.addAction(dontAllow)
            alertControl.addAction(allow)
            
            self.present(alertControl, animated: true, completion: nil)
        }
    }
    
    // MARK: - Actions
    
    @objc func tapDidTouch(sender: Any) {
        self.view.endEditing(true)
    }
    
    // MARK: @IBActions
    @IBAction func onTextFieldChanged(_ sender: MDCTextField) {
        formValidator.validateField(sender) { validationError in
            self.allTextFieldControllers[sender.tag].setErrorText(validationError?.errorMessage, errorAccessibilityValue: nil)
        }
    }
    
    @IBAction func onSignUpPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        formValidator.validate(self)
    }
    
    @IBAction func signInWithFingerPrint(_ sender: Any?) {
        let keyChain = KeychainManager()
        if let _ = keyChain.getDataFromKeychain(Constant.Keys.keyPassword), let _ = keyChain.getDataFromKeychain(Constant.Keys.keyPrivate), UserAuth.token != "" {
            let alertControl = UIAlertController(title: "Do you want to allow Authoriti to use Touch ID?", message: nil, preferredStyle: .alert)
            let dontAllow = UIAlertAction(title: "Don't allow", style: .cancel, handler: { (_) in
                UserAuth.setIsTouchId(false)
                self.goNext()
            })
            
            let allow = UIAlertAction(title: "Allow", style: .default, handler: { (_) in
                if BioMetricAuthenticator.canAuthenticate() {
                    UserAuth.setIsTouchId(true)
                    self.goNext()
                } else {
                    self.showEnableTouchId()
                }
            })
            
            alertControl.addAction(dontAllow)
            alertControl.addAction(allow)
            
            self.present(alertControl, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserVerificationSegue" {
            UserPreference.currentUser.password = txtPasswd.text
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SignUpWithInviteViewController: ValidationDelegate {
    func validationSuccessful() {
        proceedSignup()
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (field, error) in errors {
            if let field = field as? UITextField {
                allTextFieldControllers[field.tag].setErrorText(error.errorMessage, errorAccessibilityValue: nil)
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension SignUpWithInviteViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let index = textField.tag
        if index + 1 < allTextFieldControllers.count,
            let nextField = allTextFieldControllers[index + 1].textInput {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}

// MARK: - Keyboard Handling

extension SignUpWithInviteViewController {
    func registerKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillShow(notif:)),
            name: .UIKeyboardWillChangeFrame,
            object: nil)
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillShow(notif:)),
            name: .UIKeyboardWillShow,
            object: nil)
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillHide(notif:)),
            name: .UIKeyboardWillHide,
            object: nil)
    }
    
    @objc func keyboardWillShow(notif: Notification) {
        guard let frame = notif.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        scrollView.contentInset = UIEdgeInsets(top: 0.0,
                                               left: 0.0,
                                               bottom: frame.height,
                                               right: 0.0)
    }
    
    @objc func keyboardWillHide(notif: Notification) {
        scrollView.contentInset = UIEdgeInsets()
    }
}

extension SignUpWithInviteViewController: RegistrationService {
    func userSignUpSuccess(_ response: [String : Any]) {
        if let accounts = response[APIKeys.Login.keyUpdateAccounts] as? [String] {
            self.confirmNeededAccounts = accounts
        }
        
        self.signInWithFingerPrint(nil)
    }
    
    func userSignUpFailed() {
        
    }
}
