//
//  PasscodeOptionsTableViewCell.swift
//  CurtisDigital
//
//  Created by mobilestar on 11/16/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit

class PasscodeOptionsTableViewCell: MDTableViewCell {

    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var checkedImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureTableCell(_ index: Int, option: PickerOptionType, selectedOption: Any, purpose: Purpose) {
        
        guard let schema = purpose.getSchema() else {
            return
        }
        
        switch option {
        case .accountId:
           let accountId = UserPreference.currentUser.accounts[index]
            self.optionLabel.text = accountId.type
            if accountId.type == (selectedOption as! AccountID).type, accountId.id == (selectedOption as! AccountID).id {
                self.checkedImageView.isHidden = false
            } else {
                self.checkedImageView.isHidden = true
            }

            break
        case .time:
            if let expiryTime = ExpireTimeOption(rawValue: index) {
                self.optionLabel.text = expiryTime.getStringValue()
                if expiryTime == (selectedOption as! ExpireTime).option {
                    self.checkedImageView.isHidden = false
                } else {
                    self.checkedImageView.isHidden = true
                }
            }
            break
        case .industry:
            if let industries = schema.options.filter({$0.picker == .industry}).first?.values {
                self.optionLabel.text = industries[index].title
                if industries[index].title == (selectedOption as! DetailOptions).title {
                    self.checkedImageView.isHidden = false
                } else {
                    self.checkedImageView.isHidden = true
                }
            } else {
                self.optionLabel.text = ""
            }
            break
        case .location:
            if let locations = schema.options.filter({$0.picker == .location}).first?.values {
                self.optionLabel.text = locations[index].title
                if locations[index].title == (selectedOption as! DetailOptions).title {
                    self.checkedImageView.isHidden = false
                } else {
                    self.checkedImageView.isHidden = true
                }
            } else {
                self.optionLabel.text = ""
            }
            break
        case .geo:
            if let locations = schema.options.filter({$0.picker == .geo}).first?.values {
                self.optionLabel.text = locations[index].title
                if locations[index].title == (selectedOption as! DetailOptions).title {
                    self.checkedImageView.isHidden = false
                } else {
                    self.checkedImageView.isHidden = true
                }
            } else {
                self.optionLabel.text = ""
            }
            break
        case .requestor:
            if let requestors = schema.options.filter({$0.picker == .requestor}).first?.values {
                self.optionLabel.text = requestors[index].title
                if requestors[index].title == (selectedOption as! DetailOptions).title {
                    self.checkedImageView.isHidden = false
                } else {
                    self.checkedImageView.isHidden = true
                }
            } else {
                self.optionLabel.text = ""
            }
            break
            
        default:
            break
        }
    }

    func configureCellForDataType(_ dataType: DataType, index: Int, selectedOption: Any) {
        
        if let selectedOption = selectedOption as? [DetailOptions] {
            if let _ = selectedOption.filter({$0.title == dataType.options[index].title}).first {
                self.checkedImageView.isHidden = false
            } else {
                self.checkedImageView.isHidden = true
            }
        } else {
            self.checkedImageView.isHidden = true
        }
        
        self.optionLabel.text = dataType.options[index].title
    }
    
}
