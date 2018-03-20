//
//  PurposeTableViewCell.swift
//  CurtisDigital
//
//  Created by mobilestar on 2/27/18.
//  Copyright © 2018 Mark. All rights reserved.
//

import UIKit
import MaterialComponents

class PurposeTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var optionLabel: UILabel!
    
    @IBOutlet weak var defaultView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.accessoryView = UIImageView(image: #imageLiteral(resourceName: "icon_disclosure"))
        self.defaultView.layer.cornerRadius = 5.0
        self.defaultView.layer.masksToBounds = true
    }

    func configureTableCell(_ purpose: Purpose) {
        self.optionLabel.text = purpose.title
        
        if let defaultValue = Purpose.getDefaultPurpose(), purpose.title == defaultValue {
            self.defaultView.isHidden = false
        } else {
            self.defaultView.isHidden = true
        }
    }

}
