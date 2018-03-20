//
//  AddNewPasscodeViewController.swift
//  CurtisDigital
//
//  Created by Jannes on 11/14/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import MaterialComponents

class AddNewPasscodeViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var generatePasscodeButton: MDCButton!
    
    var purpose: Purpose!
    var passcode: Passcode!
    
    var trustedCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create an instance to generate a new passcode
        self.setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadSchemas), name: NSNotification.Name(rawValue: "ReloadSchema"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print(passcode)
        self.tableView.reloadData()
    }
    
    func setupViews() {
        self.passcode = Passcode.setAsDefault(purpose)
        self.tableView.register(UINib.init(nibName: "TrustedInputTableCell", bundle: nil), forCellReuseIdentifier: "TrustedInputTableCell")
    }
    
    @objc func reloadSchemas() {
        self.passcode = Passcode.setAsDefault(purpose)
        self.tableView.reloadData()
    }
    
    // MARK: - IBAction
    @IBAction func generatePasscode(_ sender: MDCButton) {
        
        if let schemaNum = self.purpose.numSchema, schemaNum == 1 {
            let payload = EcDSA().addAccountIdToPayload(accountId: passcode.selectedAccount.id.trimSpecialCharactors(), payload: passcode.generatePayload())
            self.passcode.code = AppManager.sharedInstance.generatePasscode(payload)
        } else {
            
            if let code = self.trustedCode, code != "" {
                let accountIdWithIdentifier = EcDSA().addIdentifierToAccountId(identifier: code, accountId: passcode.selectedAccount.id.trimSpecialCharactors())
                let payload = EcDSA().addAccountIdToPayload(accountId: accountIdWithIdentifier, payload: passcode.generatePayload())
                self.passcode.code = AppManager.sharedInstance.generatePasscode(payload)
            } else {
                self.showErrorMessage("Please enter the code provided by the Company you wisk to grant access.")
                return
            }
        }
        
        let dialogController = MDCDialogTransitionController()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let generatedPasscodeController = storyboard.instantiateViewController(withIdentifier: "PasscodeGenerateDialogController") as! PasscodeGenerateDialogController
        let navVC = BaseNavViewController(rootViewController: generatedPasscodeController)
        generatedPasscodeController.passcode = self.passcode
        navVC.modalPresentationStyle = .overFullScreen
        navVC.transitioningDelegate = dialogController
        
        self.present(navVC, animated: true, completion: nil)
    }
    
    @IBAction func goHelper(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let helpVC = storyboard.instantiateViewController(withIdentifier: "HelpViewController")
        let navigation = BaseNavViewController(rootViewController: helpVC)
        self.present(navigation, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickOptionSegue" {
            
            guard let indexPath = sender as? IndexPath, let schema = purpose.getSchema() else {
                return
            }
            
            let availableOptions = schema.options.filter { (option) -> Bool in
                return (option.picker != .country && option.picker != self.purpose.exceptPickerType)
            }
            
            let picker = availableOptions[indexPath.row]
            
            let pickOptionVC = segue.destination as! PickPasscodeOptionViewController
            pickOptionVC.purpose = self.purpose
            pickOptionVC.passcode = passcode
            pickOptionVC.passcodeOption = picker.picker
            pickOptionVC.titleString = picker.title
        }
    }
}

extension AddNewPasscodeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.purpose.numSchema ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        }
        
        return purpose.getPickerCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrustedInputTableCell") as! TrustedInputTableCell
            cell.delegate = self
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreatePasscodeTableViewCell") as! CreatePasscodeTableViewCell
        
        if let schema = self.purpose.getSchema() {
            let availableOptions = schema.options.filter { (option) -> Bool in
                return (option.picker != .country && option.picker != self.purpose.exceptPickerType)
            }
            
            let picker = availableOptions[indexPath.row]
            cell.configureTableCell(self.passcode, option: picker, purpose: self.purpose)
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 1 {
            
        } else {
            self.performSegue(withIdentifier: "PickOptionSegue", sender: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 80.0
        }
        
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 40.0
        }
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 0.1
        }
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30.0))
            view.backgroundColor = UIColor.clear
            return view
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            return nil
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30.0))
        let label = UILabel()
        label.text = "Click to change, or swipe left or right to set as default"
        label.font = Fonts.textField.textFont
        label.textColor = Colors.CreatePasscode.textColor
        label.sizeToFit()
        label.center = view.center
        view.addSubview(label)
        return view
    }
}

extension AddNewPasscodeViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        guard orientation == .left else { return nil }

        let saveAsDefault = SwipeAction(style: .default, title: "Save As Default") { (_, index) in
            guard let schema = self.purpose.getSchema() else {
                return
            }
            
            let availableOptions = schema.options.filter { (option) -> Bool in
                return (option.picker != .country && option.picker != self.purpose.exceptPickerType)
            }
            
            let picker = availableOptions[indexPath.row]
            switch picker.picker {
            case .industry:
                AppManager.sharedInstance.saveDefaultOptionsToUserDefault(picker.picker, detailOption: self.passcode.industryOption, purpose: self.purpose.title ?? "")
            case .location:
                AppManager.sharedInstance.saveDefaultOptionsToUserDefault(picker.picker, detailOption: self.passcode.stateOption, purpose: self.purpose.title ?? "")
            case .geo:
                AppManager.sharedInstance.saveDefaultOptionsToUserDefault(picker.picker, detailOption: self.passcode.geoOption, purpose: self.purpose.title ?? "")
            case .time:
                AppManager.sharedInstance.saveDefaultOptionsToUserDefault(.time, detailOption: nil, expireTime: self.passcode.expireTime, purpose: self.purpose.title ?? "")
            case .accountId:
                AppManager.sharedInstance.saveDefaultOptionsToUserDefault(picker.picker, detailOption: nil, accountId: self.passcode.selectedAccount.id, purpose: "account")
            case .requestor:
                AppManager.sharedInstance.saveDefaultOptionsToUserDefault(picker.picker, detailOption: self.passcode.requestorOption, purpose: self.purpose.title ?? "")
            case .dataType:
                AppManager.sharedInstance.saveDefaultOptionsToUserDefault(picker.picker, detailOption: self.passcode.dataTypeOption, purpose: self.purpose.title ?? "")
            default:
                break
            }
            
            self.tableView.reloadData()
        }
        
        saveAsDefault.hidesWhenSelected = true
        saveAsDefault.backgroundColor = Colors.CreatePasscode.saveButtonColor
        
        return [saveAsDefault]
    }
}

extension AddNewPasscodeViewController: TrustedInputTableCellDelegate {
    func trustedThirdPartyCode(_ code: String?) {
        self.trustedCode = code
    }
}
