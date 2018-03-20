//
//  CompleteSignUpViewController.swift
//  CurtisDigital
//
//  Created by Jannes on 11/14/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import MaterialComponents
import SwiftValidator

class ForgotPasswordViewController: BaseViewController {

    @IBOutlet weak var txtCurrentPWField: MDCTextField!
    @IBOutlet weak var txtNewPWField: MDCTextField!
    @IBOutlet weak var txtConfirmPWField: MDCTextField!
    
    var txtCurrentPWController: MDCTextInputControllerDefault?
    var txtNewPWController: MDCTextInputControllerDefault?
    var txtConfirmPWController: MDCTextInputControllerDefault?
    
    var allTextFieldControllers = [MDCTextInputControllerDefault]()
    
    let formValidator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupValidateRules()
        self.setupViews()
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
        
        if let passwordData = KeychainManager().getDataFromKeychain(Constant.Keys.keyPassword), let password = String.init(data: passwordData, encoding: .utf8) {
            formValidator.registerField(txtCurrentPWField, rules: [RequiredRule(), EqualRule(equalString: password, message: "Password doesn't match with currnet Password")])
        }
        
        formValidator.registerField(txtNewPWField, rules: [RequiredRule()])
        formValidator.registerField(txtConfirmPWField, rules: [RequiredRule(), ConfirmationRule(confirmField: txtNewPWField)])
    }
    
    func setupViews() {
        
        txtCurrentPWField.font                                     = Fonts.textField.textFont
        txtCurrentPWController                                     = MDCTextInputControllerDefault(textInput: txtCurrentPWField)
        txtCurrentPWController!.placeholderText                    = "Enter Current Password"
        txtCurrentPWController!.activeColor                        = Colors.appColor
        txtCurrentPWController!.inlinePlaceholderFont              = Fonts.textField.placeholderFont
        txtCurrentPWController!.leadingUnderlineLabelFont          = Fonts.textField.errorFont
        allTextFieldControllers.append(txtCurrentPWController!)
        
        txtNewPWField.font                                   = Fonts.textField.textFont
        txtNewPWController                              = MDCTextInputControllerDefault(textInput: txtNewPWField)
        txtNewPWController!.placeholderText             = "Enter New Password"
        txtNewPWController!.activeColor                 = Colors.appColor
        txtNewPWController!.inlinePlaceholderFont       = Fonts.textField.placeholderFont
        txtNewPWController!.leadingUnderlineLabelFont   = Fonts.textField.errorFont
        allTextFieldControllers.append(txtNewPWController!)
        
        txtConfirmPWField.font                                   = Fonts.textField.textFont
        txtConfirmPWController                              = MDCTextInputControllerDefault(textInput: txtConfirmPWField)
        txtConfirmPWController!.placeholderText             = "Confirm New Password"
        txtConfirmPWController!.activeColor                 = Colors.appColor
        txtConfirmPWController!.inlinePlaceholderFont       = Fonts.textField.placeholderFont
        txtConfirmPWController!.leadingUnderlineLabelFont   = Fonts.textField.errorFont
        allTextFieldControllers.append(txtConfirmPWController!)
    }
    
    func validateField(_ textField: MDCTextField) {
        formValidator.validateField(textField) { validationError in
            self.allTextFieldControllers[textField.tag].setErrorText(validationError?.errorMessage, errorAccessibilityValue: nil)
        }
    }
    
    @IBAction func onTextFieldChanged(_ sender: MDCTextField) {
        self.validateField(sender)
    }
    
    @IBAction func onResetPassword(_ sender: MDCRaisedButton) {
        self.view.endEditing(true)
        // Touch ID authentiation
        formValidator.validate(self)
    }
}

extension ForgotPasswordViewController: ValidationDelegate {
    func validationSuccessful() {
        
        let newPassword = self.txtNewPWField.text ?? ""
        KeychainManager().saveDataToKeychainWith(newPassword, key: Constant.Keys.keyPassword)
        
        self.navigationController?.popViewController(animated: true)
        self.showToast("Reseted Password Successfully")
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (field, error) in errors {
            if let field = field as? UITextField {
                allTextFieldControllers[field.tag].setErrorText(error.errorMessage, errorAccessibilityValue: nil)
            }
        }
    }
}

