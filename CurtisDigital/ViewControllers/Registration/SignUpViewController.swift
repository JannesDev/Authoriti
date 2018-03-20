//
//  SignUpViewController.swift
//  CurtisDigital
//
//  Created by Jannes on 11/14/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import MaterialComponents
import SwiftValidator

class SignUpViewController: BaseViewController {
    
    @IBOutlet weak var txtPasswd: MDCTextField!
    @IBOutlet weak var txtPasswdConfirm: MDCTextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var txtPasswdController: MDCTextInputControllerDefault?,
        txtPasswdConfirmController: MDCTextInputControllerDefault?
    
    var allTextFieldControllers = [MDCTextInputControllerDefault]()
    
    let formValidator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupValidateRules()
        registerKeyboardNotifications()
        addGestureRecognizer()
    }
    
    func setupViews() {
        
        txtPasswd.font                                          = Fonts.textField.textFont
        txtPasswdController                                     = MDCTextInputControllerDefault(textInput: txtPasswd)
        txtPasswdController!.placeholderText                    = "PASSWORD"
        txtPasswdController!.activeColor                        = Colors.appColor
        txtPasswdController!.inlinePlaceholderFont              = Fonts.textField.placeholderFont
        txtPasswdController!.leadingUnderlineLabelFont          = Fonts.textField.errorFont
        allTextFieldControllers.append(txtPasswdController!)
        
        txtPasswdConfirm.font                                   = Fonts.textField.textFont
        txtPasswdConfirmController                              = MDCTextInputControllerDefault(textInput: txtPasswdConfirm)
        txtPasswdConfirmController!.placeholderText             = "CONFIRM PASSWORD"
        txtPasswdConfirmController!.activeColor                 = Colors.appColor
        txtPasswdConfirmController!.inlinePlaceholderFont       = Fonts.textField.placeholderFont
        txtPasswdConfirmController!.leadingUnderlineLabelFont   = Fonts.textField.errorFont
        allTextFieldControllers.append(txtPasswdConfirmController!)
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
        
        formValidator.registerField(txtPasswd, rules: [RequiredRule()])
        formValidator.registerField(txtPasswdConfirm, rules: [RequiredRule(), ConfirmationRule(confirmField: txtPasswd)])
    }
    
    func proceedSignup() {
        /*
        let messageTitle = "Driver's License Validation"
        let messageString = "We need to make sure you are who you say you are. We need you to take pictures of your driver's license"
        
        let materialAlertController = MDCAlertController(title: messageTitle, message: messageString)
        
        let action = MDCAlertAction(title: "OK") { (_) in
            self.performSegue(withIdentifier: "UserVerificationSegue", sender: nil)
        }
        
        materialAlertController.addAction(action)
        
        self.present(materialAlertController, animated: true, completion: nil)
         */
        self.performSegue(withIdentifier: "UserVerificationSegue", sender: nil)
    }
    
    func addGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(tapDidTouch(sender: )))
        self.scrollView.addGestureRecognizer(tapRecognizer)
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

extension SignUpViewController: ValidationDelegate {
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

extension SignUpViewController: UITextFieldDelegate {
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

extension SignUpViewController {
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
