//
//  PasscodeGenerateDialogController.swift
//  CurtisDigital
//
//  Created by mobilestar on 11/16/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import QRCode

class PasscodeGenerateDialogController: BaseViewController {

    var passcode: Passcode!
    
    @IBOutlet weak var txtPasscode: UITextView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    @IBOutlet weak var permissionCodeContentView: UIView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var buttonShadowView: UIView!
    @IBOutlet weak var shadowView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.txtPasscode.textColor = Colors.PasscodeGeneration.qrCodeColor
        let attributeForNumber = [
            NSAttributedStringKey.foregroundColor: UIColor(hex: "DB381B"),
            NSAttributedStringKey.font: UIFont(name: "Inconsolata-Bold", size: 30.0)!
        ]
        
        let attribute = [
            NSAttributedStringKey.foregroundColor: Colors.PasscodeGeneration.qrCodeColor,
            NSAttributedStringKey.font: UIFont(name: "Inconsolata-Bold", size: 30.0)!
        ]
        
        if let code = passcode.code {
            let attributeString = NSMutableAttributedString()
            for char in code.characters {
                if let _ = Int(String(char)) {
                    attributeString.append(NSAttributedString(string: String(char), attributes: attributeForNumber))
                } else {
                    attributeString.append(NSAttributedString(string: String(char), attributes: attribute))
                }
            }
            
            self.txtPasscode.attributedText = attributeString
            self.txtPasscode.textAlignment = .center
            UIPasteboard.general.string = code
        }
        
        self.qrCodeImageView.image = self.generateQRCode()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupViews()
    }
    
    func setupViews() {
        permissionCodeContentView.setRoundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
        buttonView.setRoundCorners([.topRight, .topLeft], radius: 10.0)
        shadowView.setShadow(Colors.PasscodeGeneration.contentShadowColor, shadowOpacity: 0.25, shadowOffset: CGSize(width: 0, height: 5), shadowRadius: 10, cornerRadius: 10.0)
        buttonShadowView.setShadow(Colors.PasscodeGeneration.contentShadowColor, shadowOpacity: 0.25, shadowOffset: CGSize(width: 0, height: 5), shadowRadius: 10, cornerRadius: 10.0)
    }
    
    // Generate QR Code
    
    func generateQRCode() -> UIImage? {
        guard let code = passcode.code else {
            return nil
        }
        
        let qrcodeString = "\(code)"
        
        if let qrCodeData = qrcodeString.data(using: .isoLatin1, allowLossyConversion: false) {
            var qrCode = QRCode(qrCodeData)
            qrCode.color = Colors.PasscodeGeneration.qrCodeColor.coreImageColor
            return qrCode.image
        }
        
        return nil
    }
    
    @IBAction func dismissDialog(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
