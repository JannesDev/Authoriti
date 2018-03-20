//
//  TimePickerDialogViewController.swift
//  CurtisDigital
//
//  Created by mobilestar on 12/21/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import MaterialComponents
import SwiftValidator
import BEMCheckBox

protocol InputAccountDialogControllerDelegate {
    func createNewAccount(_ account: AccountID, isDefault: Bool)
}

class InputAccountDialogController: UIViewController {

    @IBOutlet weak var underView: ShadowedView!
    
    @IBOutlet weak var txtAccountName: MDCTextField!
    @IBOutlet weak var txtAccountValue: MDCTextField!
    @IBOutlet weak var saveAsDefault: BEMCheckBox!
    
    var txtNameController: MDCTextInputControllerDefault!
    var txtValueController: MDCTextInputControllerDefault!
    
    var allTextFieldControllers = [MDCTextInputControllerDefault]()
    
    let formValidator = Validator()
    
    var isSaveAsDefault: Bool = false
    
    var delegate: InputAccountDialogControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViews()
        self.setupValidateRules()
    }

    func setupViews() {
        txtAccountName.font                              = Fonts.textField.textFont
        txtNameController                                = MDCTextInputControllerDefault(textInput: txtAccountName)
        txtNameController.placeholderText                = "Name this ID"
        txtNameController.activeColor                    = Colors.appColor
        txtNameController.inlinePlaceholderFont          = Fonts.textField.placeholderFont
        txtNameController.leadingUnderlineLabelFont      = Fonts.textField.errorFont
        allTextFieldControllers.append(txtNameController)
        
        txtAccountValue.font                 = Fonts.textField.textFont
        txtValueController                                 = MDCTextInputControllerDefault(textInput: txtAccountValue)
        txtValueController.placeholderText                = "ID Number"
        txtValueController.activeColor                    = Colors.appColor
        txtValueController.inlinePlaceholderFont          = Fonts.textField.placeholderFont
        txtValueController.leadingUnderlineLabelFont      = Fonts.textField.errorFont
        
        allTextFieldControllers.append(txtValueController)
        
        self.saveAsDefault.onTintColor = Colors.appColor
        self.saveAsDefault.onCheckColor = UIColor.white
        self.saveAsDefault.onFillColor = Colors.appColor
        self.saveAsDefault.boxType = .square
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onClickCancel))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func validateField(_ textField: MDCTextField) {
        formValidator.validateField(textField) { validationError in
            self.allTextFieldControllers[textField.tag].setErrorText(validationError?.errorMessage, errorAccessibilityValue: nil)
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
            if let textField = validationError.field as? MDCTextField {
                self.allTextFieldControllers[textField.tag].setErrorText(validationError.errorMessage, errorAccessibilityValue: nil)
            }
        })
        
        formValidator.registerField(txtAccountName, rules: [RequiredRule()])
        formValidator.registerField(txtAccountValue, rules: [RequiredRule()])
    }
    
    @IBAction func onClickCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickSave() {
        formValidator.validate(self)
    }
    
    @IBAction func didSetAsDefault(_ sender: BEMCheckBox) {
        self.isSaveAsDefault = sender.on
    }
    
    @IBAction func textDidChange(_ sender: MDCTextField) {
        self.validateField(sender)
    }
    
}

extension InputAccountDialogController: ValidationDelegate {
    func validationSuccessful() {
        let account = AccountID(type: self.txtAccountName.text ?? "", id: self.txtAccountValue.text ?? "")
        self.delegate?.createNewAccount(account, isDefault: self.isSaveAsDefault)
        self.dismiss(animated: true, completion: nil)
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (field, error) in errors {
            if let field = field as? MDCTextField {
                allTextFieldControllers[field.tag].setErrorText(error.errorMessage, errorAccessibilityValue: nil)
            }
        }
    }
}
