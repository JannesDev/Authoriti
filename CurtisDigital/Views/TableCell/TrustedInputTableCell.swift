//
//  TrustedInputTableCell.swift
//  CurtisDigital
//
//  Created by mobilestar on 2/27/18.
//  Copyright © 2018 Mark. All rights reserved.
//

import UIKit
import MaterialComponents

protocol TrustedInputTableCellDelegate {
    func trustedThirdPartyCode(_ code: String?)
}

class TrustedInputTableCell: UITableViewCell {

    @IBOutlet weak var trustedTxtField: MDCTextField!
    
    var txtTrustedController: MDCTextInputControllerDefault?
    
    var delegate: TrustedInputTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        trustedTxtField.delegate                                = self
        trustedTxtField.font                                    = Fonts.textField.textFont
        txtTrustedController                                    = MDCTextInputControllerDefault(textInput: trustedTxtField)
        txtTrustedController!.placeholderText                   = "Enter the Code Provided by the Company You Wish to Grant Access"
        txtTrustedController!.activeColor                       = Colors.appColor
        txtTrustedController!.inlinePlaceholderFont             = Fonts.textField.placeholderFont
        txtTrustedController!.leadingUnderlineLabelFont         = Fonts.textField.errorFont
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension TrustedInputTableCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        txtTrustedController?.placeholderText = "Enter the Code"
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.txtTrustedController?.placeholderText = "Enter the Code Provided by the Company You Wish to Grant Access"
        self.delegate?.trustedThirdPartyCode(textField.text)
        return true
    }
}
