//
//  InviteCodeViewController.swift
//  CurtisDigital
//
//  Created by mobilestar on 12/6/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import MaterialComponents
import SwiftValidator

enum SignUpType: Int {
    case hasCustomer = 0
    case noCustomer
}

class InviteCodeViewController: BaseViewController {

    @IBOutlet weak var txtInviteCode: MDCTextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var txtInviteCodeController: MDCTextInputControllerDefault?
    
    let formValidator = Validator()
    
    var registrationService: RegistrationService?
    
    var dummyType: SignUpType = .noCustomer
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.registrationService = self
        
        setupViews()
        setupValidateRules()
        registerKeyboardNotifications()
        addGestureRecognizer()
    }
    
    func setupViews() {
        
        txtInviteCode.font                                          = Fonts.textField.textFont
        txtInviteCodeController                                     = MDCTextInputControllerDefault(textInput: txtInviteCode)
        txtInviteCodeController!.placeholderText                    = "INVITE CODE"
        txtInviteCodeController!.activeColor                        = Colors.appColor
        txtInviteCodeController!.inlinePlaceholderFont              = Fonts.textField.placeholderFont
        txtInviteCodeController!.leadingUnderlineLabelFont          = Fonts.textField.errorFont
    }
    
    func setupValidateRules() {
        
        formValidator.styleTransformers(success:{ (validationRule) -> Void in
            // clear error label
            if validationRule.field is MDCTextField {
                self.txtInviteCodeController?.setErrorText(nil, errorAccessibilityValue: nil)
            }
        }, error:{ (validationError) -> Void in
            if validationError.field is UITextField {
                self.txtInviteCodeController?.setErrorText(validationError.errorMessage, errorAccessibilityValue: nil)
            }
        })
        
        formValidator.registerField(txtInviteCode, rules: [RequiredRule()])
    }
    
    func addGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(tapDidTouch(sender: )))
        self.scrollView.addGestureRecognizer(tapRecognizer)
    }
    
    func goToSignUp() {
        self.registrationService?.validateInviteCode(self.txtInviteCode.text ?? "")
    }
    
    // MARK: - Actions
    
    @objc func tapDidTouch(sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func onTextFieldChanged(_ sender: MDCTextField) {
        formValidator.validateField(sender) { validationError in
            self.txtInviteCodeController?.setErrorText(validationError?.errorMessage, errorAccessibilityValue: nil)
        }
    }
    
    @IBAction func onNextButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        
        formValidator.validate(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FirstSignUpFlowSegue" {
            
        } else if segue.identifier == "SecondSignUpFlowSegue" {
            guard let customer = sender as? String else {
                return
            }
            
            let signUpVC = segue.destination as! SignUpWithInviteViewController
            signUpVC.customerName = customer
        }
    }
}

extension InviteCodeViewController: ValidationDelegate {
    func validationSuccessful() {
        self.goToSignUp()
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (field, error) in errors {
            if field is UITextField {
                txtInviteCodeController?.setErrorText(error.errorMessage, errorAccessibilityValue: nil)
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension InviteCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtInviteCode.resignFirstResponder()
        formValidator.validate(self)
        return false
    }
}

// MARK: - Keyboard Handling

extension InviteCodeViewController {
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

extension InviteCodeViewController: RegistrationService {
    func validationFailed() {
        
    }
    
    func validationSuccess(_ isValid: Bool, customer: String) {
        self.dummyType = (customer == "") ? .noCustomer : .hasCustomer
        UserPreference.currentUser.inviteCode = self.txtInviteCode.text ?? ""
        if dummyType == .noCustomer {
            self.performSegue(withIdentifier: "FirstSignUpFlowSegue", sender: nil)
        } else {
            self.performSegue(withIdentifier: "SecondSignUpFlowSegue", sender: customer)
        }
    }
}

