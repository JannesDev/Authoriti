//
//  PickPasscodeOptionViewController.swift
//  CurtisDigital
//
//  Created by mobilestar on 11/16/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import MaterialComponents

class PickPasscodeOptionViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var titleLabel: UILabel!
    
    var purpose: Purpose!
    var passcode: Passcode!
    var passcodeOption: PickerOptionType?
    var titleString: String?
    
    var accounts: [AccountID] = [AccountID]()
    
    var selectedOption: Any!
    
    var timePicker: MDTimePickerDialog!
    var datePicker: MDDatePickerDialog!
    
    var selectedDate: Date!
    
    var isTimeOnly: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "PasscodeOptionsTableViewCell", bundle: nil), forCellReuseIdentifier: "optionCell")
        
        self.titleLabel.text = (titleString == "") ? passcodeOption?.getHeaderTitle().uppercased() : titleString?.uppercased()
        self.tableView.allowsMultipleSelection = false
                
        if let options = self.passcodeOption {
            switch options {
            case .accountId:
                self.selectedOption = passcode.selectedAccount
                self.accounts = UserPreference.currentUser.accounts.reduce(into: [], { (result, account) in
                    if account.id != "" {
                        result.append(account)
                    }
                })
                break
            case .time:
                self.selectedOption = passcode.expireTime
                break
            case .industry:
                self.selectedOption = passcode.industryOption
                break
            case .location:
                self.selectedOption = passcode.stateOption
                break
            case .geo:
                self.selectedOption = passcode.geoOption
                break
            case .requestor:
                self.selectedOption = passcode.requestorOption
            case .dataType:
                self.selectedOption = passcode.dataTypeOption
                self.tableView.allowsMultipleSelection = true
            default:
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showDatePickerDialog() {
        
        self.datePicker = MDDatePickerDialog()
        var components = DateComponents()
        let expireTime = self.selectedOption as! ExpireTime
        if expireTime.dateCompoment == .day {
            components.day = expireTime.duration
        } else {
            components.minute = expireTime.duration
        }
        
        var minComponent = DateComponents()
        minComponent.day = 1
        datePicker.minimumDate = Calendar.current.date(byAdding: minComponent, to: Calendar.current.startOfDay(for: Date()))!
        datePicker.selectedDate = Calendar.current.date(byAdding: components, to: Date())!
        datePicker.delegate = self
        
        self.isTimeOnly = false
        
        datePicker.show()
    }
    
    // MARK: - IBAction

    func savePasscodeOption() {
        if let options = self.passcodeOption {
            switch options {
            case .accountId:
                self.passcode.selectedAccount = selectedOption as! AccountID
                self.goBack(nil)
                break
            case .time:
                self.passcode.expireTime = selectedOption as! ExpireTime
                self.goBack(nil)
                break
            case .industry:
                self.passcode.industryOption = selectedOption as! DetailOptions
                self.goBack(nil)
                break
            case .location:
                self.passcode.stateOption = selectedOption as! DetailOptions
                self.goBack(nil)
                break
            case .geo:
                self.passcode.geoOption = selectedOption as! DetailOptions
                self.goBack(nil)
                break
            case .requestor:
                self.passcode.requestorOption = selectedOption as! DetailOptions
                
                if let dataType = AppManager.sharedInstance.datatypes.filter({$0.requestor == passcode.requestorOption.value}).first {
                    var isMatch: Bool = true
                    self.passcode.dataTypeOption.forEach({ (option) in
                        let isContain = dataType.options.contains(where: { (detailOption) -> Bool in
                            return option.title == detailOption.title
                        })
                        
                        if !isContain {
                            isMatch = false
                        }
                    })
                    
                    if !isMatch {
                        self.passcode.dataTypeOption = [dataType.options.first!]
                    }
                }
                
                self.goBack(nil)
                
                break
            case .dataType:
                self.passcode.dataTypeOption = selectedOption as! [DetailOptions]
                break
            default:
                break
            }
        }
    }
    
    @IBAction func goBack(_ sender: MDButton?) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func didChooseOption(_ index: Int) {
        if let options = self.passcodeOption {
            switch options {
            case .accountId:
                let accountId = self.accounts[index]
                self.selectedOption = accountId
                self.tableView.reloadData()
                self.savePasscodeOption()
                break
            case .time:
                
                if let expiryTime = ExpireTimeOption(rawValue: index), expiryTime == .customDateTime {
                    self.showDatePickerDialog()
                } else if let expiryTime = ExpireTimeOption(rawValue: index), expiryTime == .customTime {
                    self.isTimeOnly = true
                    self.showTimePicker()
                } else if let expiryTime = ExpireTimeOption(rawValue: index) {
                    // TODO: - will implement custom time input
                    self.selectedOption = expiryTime.getExpireTime()
                    self.tableView.reloadData()
                    self.savePasscodeOption()
                }
                
                break
            case .industry:
                
                guard let schema = self.purpose.getSchema() else {
                    return
                }
                
                if let industry = schema.options.filter({$0.picker == .industry}).first?.values[index] {
                    self.selectedOption = industry
                }
                self.tableView.reloadData()
                self.savePasscodeOption()
                break
            case .location:
                
                guard let schema = self.purpose.getSchema() else {
                    return
                }
                
                if let location = schema.options.filter({$0.picker == .location}).first?.values[index] {
                    self.selectedOption = location
                }
                self.tableView.reloadData()
                self.savePasscodeOption()
                break
                
            case .geo:
                
                guard let schema = self.purpose.getSchema() else {
                    return
                }
                
                if let location = schema.options.filter({$0.picker == .geo}).first?.values[index] {
                    self.selectedOption = location
                }
                self.tableView.reloadData()
                self.savePasscodeOption()
                break
                
            case .requestor:
                
                guard let schema = self.purpose.getSchema() else {
                    return
                }
                
                if let requester = schema.options.filter({$0.picker == .requestor}).first?.values[index] {
                    self.selectedOption = requester
                }
                self.tableView.reloadData()
                self.savePasscodeOption()
                break
                
            case .dataType:
                guard let dataType = AppManager.sharedInstance.datatypes.filter({$0.requestor == self.passcode.requestorOption.value}).first else {
                    return
                }
                
                if let selectedOption = self.selectedOption as? [DetailOptions] {
                    var options = selectedOption
                    if let option = selectedOption.filter({$0.title == dataType.options[index].title}).first {
                        if selectedOption.count > 1 {
                            options.remove(at: options.index(where: {$0.title == option.title})!)
                        }
                    } else {
                        options.append(dataType.options[index])
                    }
                    
                    self.selectedOption = options
                }
                
                self.tableView.reloadData()
                self.savePasscodeOption()
                
                break
            default:
                break
            }
        }
    }
    
    @objc func showTimePicker() {
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
        if self.isTimeOnly {
            dateComponents.hour = 0
            dateComponents.minute = 0
        }
        
        self.timePicker = MDTimePickerDialog(hour: dateComponents.hour ?? 0, minute: dateComponents.minute ?? 0, clockMode: MDClockMode.mode24H)
        self.timePicker.theme = .light
        self.timePicker.headerBackgroundColor = Colors.appColor
        self.timePicker.selectionColor = Colors.appColor
        self.timePicker.delegate = self
        
        self.timePicker.show()
    }
}

extension PickPasscodeOptionViewController: MDTimePickerDialogDelegate {
    func timePickerDialog(_ timePickerDialog: MDTimePickerDialog, didSelectHour hour: Int, andMinute minute: Int) {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        if isTimeOnly {
            let expireDate = ExpireTime(option: .customTime, duration: hour * 60 + minute, dateCompoment: .minute)
            self.selectedOption = expireDate
        } else {
            var compoments = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
            compoments.second = 0
            let currentDate = Calendar.current.date(from: compoments)!
           
            let date = Calendar.current.date(byAdding: dateComponents, to: Calendar.current.startOfDay(for: self.selectedDate))
            let components = Calendar.current.dateComponents([.minute], from: currentDate, to: date!)
            
            let expireDate = ExpireTime(option: .customDateTime, duration: components.minute ?? 0, dateCompoment: .minute)
            self.selectedOption = expireDate
        }
        
        self.tableView.reloadData()
        self.savePasscodeOption()
    }
}

extension PickPasscodeOptionViewController: MDDatePickerDialogDelegate {
    func datePickerDialogDidSelect(_ date: Date) {
        self.selectedDate = date
        
        self.showTimePicker()
//        self.perform(#selector(self.showTimePicker), with: nil, afterDelay: 1.0)
    }
}

extension PickPasscodeOptionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let options = self.passcodeOption, let schema = self.purpose.getSchema() else {
            return 0
        }
        
        switch options {
        case .accountId:
            return self.accounts.count
        case .time:
            return ExpireTimeOption.count()
        case .industry:
            return schema.options.filter({$0.picker == .industry}).first?.values.count ?? 0
        case .location:
            return schema.options.filter({$0.picker == .location}).first?.values.count ?? 0
        case .geo:
            return schema.options.filter({$0.picker == .geo}).first?.values.count ?? 0
        case .requestor:
            return schema.options.filter({$0.picker == .requestor}).first?.values.count ?? 0
        case .dataType:
            return AppManager.sharedInstance.datatypes.filter({$0.requestor == self.passcode.requestorOption.value}).first?.options.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell") as! PasscodeOptionsTableViewCell
        

        if let options = self.passcodeOption, options != .dataType {
            cell.configureTableCell(indexPath.row, option: options, selectedOption: self.selectedOption, purpose: self.purpose)
        } else if let options = self.passcodeOption, options == .dataType, let dataType = AppManager.sharedInstance.datatypes.filter({$0.requestor == self.passcode.requestorOption.value}).first {
            cell.configureCellForDataType(dataType, index: indexPath.row, selectedOption: self.selectedOption)
        }
        
        if let option = self.passcodeOption, option == .time, (selectedOption as! ExpireTime).option == .customDateTime, indexPath.row == 6 {
            cell.optionLabel.text = "Custom Date/Time : "
            if let expireTime = self.selectedOption as? ExpireTime {
                var dateComponents = DateComponents()
                if expireTime.dateCompoment == .minute {
                    var compoments = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
                    compoments.second = 0
                    let currentDate = Calendar.current.date(from: compoments)!
                    
                    dateComponents.minute = passcode.expireTime.duration
                    let expireDate = Calendar.current.date(byAdding: dateComponents, to: currentDate)
                    let components = Calendar.current.dateComponents([.day, .hour, .minute], from: currentDate, to: expireDate!)
                    cell.optionLabel.text = expireTime.option.getStringValue()
                    
                    if let day = components.day, day != 0 {
                        cell.optionLabel.text = cell.optionLabel.text! + " - \(day) days"
                    }
                    
                    if let hours = components.hour, hours != 0 {
                        cell.optionLabel.text = cell.optionLabel.text! + " - \(hours) hours"
                    }
                    
                    if let mins = components.minute, mins != 0 {
                        cell.optionLabel.text = cell.optionLabel.text! + " - \(mins) mins"
                    }
                    
                } else if expireTime.dateCompoment == .day {
                    cell.optionLabel.text = cell.optionLabel.text! + " - \(expireTime.duration) days"
                }
            }
        }
        
        if let option = self.passcodeOption, option == .time, (selectedOption as! ExpireTime).option == .customTime, indexPath.row == 5 {
            cell.optionLabel.text = "Custom Time : "
            if let expireTime = self.selectedOption as? ExpireTime {
                var dateComponents = DateComponents()
                if expireTime.dateCompoment == .minute {
                    var compoments = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
                    compoments.second = 0
                    let currentDate = Calendar.current.date(from: compoments)!
                    
                    dateComponents.minute = passcode.expireTime.duration
                    let expireDate = Calendar.current.date(byAdding: dateComponents, to: currentDate)
                    let components = Calendar.current.dateComponents([.hour, .minute], from: currentDate, to: expireDate!)
                    cell.optionLabel.text = expireTime.option.getStringValue()
                    
                    if let hours = components.hour, hours != 0 {
                        cell.optionLabel.text = cell.optionLabel.text! + " - \(hours) hours"
                    }
                    
                    if let mins = components.minute, mins != 0 {
                        cell.optionLabel.text = cell.optionLabel.text! + " - \(mins) mins"
                    }
                    
                } else if expireTime.dateCompoment == .hour {
                    cell.optionLabel.text = cell.optionLabel.text! + " - \(expireTime.duration) hours"
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        self.didChooseOption(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}
