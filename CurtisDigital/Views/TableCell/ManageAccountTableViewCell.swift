//
//  ManageAccountTableViewCell.swift
//  CurtisDigital
//
//  Created by mobilestar on 11/22/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit

class ManageAccountTableViewCell: MDTableViewCell {

    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var defaultView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.defaultView.layer.cornerRadius = 5.0
        self.defaultView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureTableCell(_ account: AccountID) {
        accountLabel.text = account.type
        
        if let defaultAccount = AppManager.sharedInstance.defaultOptionsFromUserDefault(.accountId, purpose: "account") as? AccountID {
            if defaultAccount.id == account.id && defaultAccount.type == account.type {
                self.defaultView.isHidden = false
            } else {
                self.defaultView.isHidden = true
            }
        } else {
            self.defaultView.isHidden = true
        }
    }
}
