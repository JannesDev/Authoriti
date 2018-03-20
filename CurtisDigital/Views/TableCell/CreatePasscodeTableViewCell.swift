//
//  CreatePasscodeTableViewCell.swift
//  CurtisDigital
//
//  Created by mobilestar on 11/16/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import MaterialComponents

class CreatePasscodeTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var optionTitleLabel: UILabel!
    @IBOutlet weak var optionLabel: UILabel!
    
    @IBOutlet weak var defaultView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.accessoryView = UIImageView(image: #imageLiteral(resourceName: "icon_disclosure"))
        self.defaultView.layer.cornerRadius = 5.0
        self.defaultView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureTableCell(_ passcode: Passcode, option: PasscodeOptions, purpose: Purpose) {
        let optionString = option.label
        self.optionTitleLabel.text = optionString + " :"
        
        switch option.picker {
        case .accountId:
            self.optionLabel.text = passcode.selectedAccount.type
            if let account = AppManager.sharedInstance.defaultOptionsFromUserDefault(.accountId, purpose: "account") as? AccountID, account.id == passcode.selectedAccount.id {
                self.defaultView.isHidden = false
            } else {
                self.defaultView.isHidden = true
            }
            break
        case .time:
            if passcode.expireTime.option == .customDateTime {
                var dateComponents = DateComponents()
                if passcode.expireTime.dateCompoment == .minute {
                    var compoments = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
                    compoments.second = 0
                    let currentDate = Calendar.current.date(from: compoments)!
                    
                    dateComponents.minute = passcode.expireTime.duration
                    let expireDate = Calendar.current.date(byAdding: dateComponents, to: currentDate)
                    let components = Calendar.current.dateComponents([.day, .hour, .minute], from: currentDate, to: expireDate!)
                    self.optionLabel.text = passcode.expireTime.option.getStringValue()
                    
                    if let day = components.day, day != 0 {
                        self.optionLabel.text = self.optionLabel.text! + " - \(day) days"
                    }
                    
                    if let hours = components.hour, hours != 0 {
                        self.optionLabel.text = self.optionLabel.text! + " - \(hours) hours"
                    }
                    
                    if let mins = components.minute, mins != 0 {
                        self.optionLabel.text = self.optionLabel.text! + " - \(mins) mins"
                    }
                    
                } else if passcode.expireTime.dateCompoment == .day {
                    self.optionLabel.text = self.optionLabel.text ?? "" + " - \(passcode.expireTime.duration) days"
                }
                
            } else if passcode.expireTime.option == .customTime {
                var dateComponents = DateComponents()
                if passcode.expireTime.dateCompoment == .minute {
                    var compoments = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
                    compoments.second = 0
                    let currentDate = Calendar.current.date(from: compoments)!
                    
                    dateComponents.minute = passcode.expireTime.duration
                    let expireDate = Calendar.current.date(byAdding: dateComponents, to: currentDate)
                    let components = Calendar.current.dateComponents([.hour, .minute], from: currentDate, to: expireDate!)
                    self.optionLabel.text = passcode.expireTime.option.getStringValue()
                    
                    if let hours = components.hour, hours != 0 {
                        self.optionLabel.text = self.optionLabel.text! + " - \(hours) hours"
                    }
                    
                    if let mins = components.minute, mins != 0{
                        self.optionLabel.text = self.optionLabel.text! + " - \(mins) mins"
                    }
                    
                } else if passcode.expireTime.dateCompoment == .hour {
                    self.optionLabel.text = self.optionLabel.text ?? "" + " - \(passcode.expireTime.duration) hours"
                }
                
            } else {
                self.optionLabel.text = passcode.expireTime.option.getStringValue()
            }
            
            if let time = AppManager.sharedInstance.defaultOptionsFromUserDefault(.time, purpose: purpose.title ?? "") as? [String: Any?], let option = time["title"] as? Int, let timeOption = ExpireTimeOption(rawValue: option) {
                self.defaultView.isHidden = !(passcode.expireTime.option == timeOption)
            } else {
                self.defaultView.isHidden = true
            }
            
            break
        case .industry:
            if let option = AppManager.sharedInstance.defaultOptionsFromUserDefault(.industry, purpose: purpose.title ?? "") as? DetailOptions {
                self.defaultView.isHidden = !(passcode.industryOption.title == option.title)
            } else {
                self.defaultView.isHidden = true
            }
            self.optionLabel.text = passcode.industryOption.title
            break
        case .location:
            self.optionLabel.text = passcode.stateOption.title
            if let option = AppManager.sharedInstance.defaultOptionsFromUserDefault(.location, purpose: purpose.title ?? "") as? DetailOptions {
                self.defaultView.isHidden = !(passcode.stateOption.title == option.title)
            } else {
                self.defaultView.isHidden = true
            }
            break
        case .geo:
            self.optionLabel.text = passcode.geoOption.title
            if let option = AppManager.sharedInstance.defaultOptionsFromUserDefault(.geo, purpose: purpose.title ?? "") as? DetailOptions {
                self.defaultView.isHidden = !(passcode.geoOption.title == option.title)
            } else {
                self.defaultView.isHidden = true
            }
            break
        case .country:
            self.optionLabel.text = passcode.countryOption.title
            break
        case .requestor:
            if let option = AppManager.sharedInstance.defaultOptionsFromUserDefault(.requestor, purpose: purpose.title ?? "") as? DetailOptions {
                self.defaultView.isHidden = !(passcode.requestorOption.title == option.title)
            } else {
                self.defaultView.isHidden = true
            }
            self.optionLabel.text = passcode.requestorOption.title
        case .dataType:
            if let option = AppManager.sharedInstance.defaultOptionsFromUserDefault(.dataType, purpose: purpose.title ?? "") as? [DetailOptions], option.count != 0 {
                var isMatch: Bool = true
                if passcode.dataTypeOption.count == option.count {
                    for i in 0 ... passcode.dataTypeOption.count - 1 {
                        if passcode.dataTypeOption[i].title != option[i].title {
                            isMatch = false
                        }
                    }
                } else {
                    isMatch = false
                }
                
                self.defaultView.isHidden = !isMatch
            } else {
                self.defaultView.isHidden = true
            }
            
            self.optionLabel.text = self.getTitleFromArray(passcode.dataTypeOption)
            
            break
        }
    }
    
    func getTitleFromArray(_ options: [DetailOptions]) -> String {
        var titleString = ""
        for option in options {
            if titleString == "" {
                titleString = option.title
            } else {
                titleString = titleString + ", \(option.title)"
            }
        }
        
        return titleString
    }
}
