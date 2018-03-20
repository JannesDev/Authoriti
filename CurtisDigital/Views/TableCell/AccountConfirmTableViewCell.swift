//
//  AccountConfirmTableViewCell.swift
//  CurtisDigital
//
//  Created by mobilestar on 12/8/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import MaterialComponents

class AccountConfirmTableViewCell: MDTableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var warningView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        warningView.layer.cornerRadius = 5.0
        warningView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureTableCell(_ account: AccountID) {
        self.nameLabel.text = account.type
        self.warningLabel.isHidden = (account.id != "")
        self.warningView.isHidden = (account.id != "")
        
        if let defaultAccount = AppManager.sharedInstance.defaultOptionsFromUserDefault(.accountId, purpose: "account") as? AccountID {
            if defaultAccount.id == account.id && defaultAccount.type == account.type {
                self.warningView.isHidden = false
                self.warningView.backgroundColor = Colors.CreatePasscode.saveButtonColor
            } else {
                self.warningView.backgroundColor = Colors.warningColor
            }
        } else {
            self.warningView.backgroundColor = Colors.warningColor
        }
    }
}
