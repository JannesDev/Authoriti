//
//  InputAccountDialogController.swift
//  CurtisDigital
//
//  Created by mobilestar on 11/22/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import MaterialComponents
import SwiftValidator
import BEMCheckBox
import DropDown

class InputAccountViewController: BaseViewController {

    var isSignUp: Bool = false
    var isSaveAsDefault: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var generatePasscode: MDCRaisedButton!
    
    var service: RegistrationService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.service = self
        
        self.setupViews()
        self.setupNavItems()
        self.enableGeneratePasscode()
    }

    func setupNavItems() {
        if !isSignUp {
            let leftMenuItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_menu"), style: .plain, target: self, action: #selector(showSideMenu(_:)))
            navigationItem.leftBarButtonItem = leftMenuItem
            
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: self, action: nil)
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }
    
    func setupViews() {
        self.tableView.register(UINib.init(nibName: "AccountConfirmTableViewCell", bundle: nil), forCellReuseIdentifier: "AccountConfirmTableViewCell")
    }
    
    private func goMyPasscodes() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navController = storyboard.instantiateViewController(withIdentifier: "MainNavController")
        
        if let window = UIApplication.shared.delegate?.window {
            UIView.transition(with: window!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                let oldState: Bool = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(true)
                window?.rootViewController = navController
                UIView.setAnimationsEnabled(oldState)
            }, completion: nil)
        }
    }
    
    private func enableGeneratePasscode() {
        if UserPreference.currentUser.accounts.count == 0 {
            self.generatePasscode.isEnabled = false
        } else {
            self.generatePasscode.isEnabled = true
        }
    }
    
    func createNewAccount(_ account: AccountID) {
        let matchedAccounts = UserPreference.currentUser.accounts.filter({$0.id == account.id})
        if matchedAccounts.count > 0 {
            self.showMessage("This account is already confirmed.")
            return
        }
    
        self.service?.confirmUser(account)
    }

    func showInputDialog(_ accountType: String) {
        
        let dialogController = MDCDialogTransitionController()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let inputDialog = storyboard.instantiateViewController(withIdentifier: "ConfirmAccountDialogController") as! ConfirmAccountDialogController
        inputDialog.delegate = self
        inputDialog.accountType = accountType
        inputDialog.modalPresentationStyle = .overFullScreen
        inputDialog.modalTransitionStyle = .crossDissolve
        inputDialog.transitioningDelegate = dialogController
        
        self.present(inputDialog, animated: true, completion: nil)
    }
    
    // MARK: - IBAction
    
    @IBAction func completeSignUp(_ sender: Any?) {
        UserAuth.setIsLoggedIn(true)
        UserAuth.setLastTime()
        
        self.goMyPasscodes()
    }
    
    @IBAction func goHelper(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let helpVC = storyboard.instantiateViewController(withIdentifier: "HelpViewController")
        let navigation = BaseNavViewController(rootViewController: helpVC)
        self.present(navigation, animated: true, completion: nil)
    }
    
    @IBAction func goGenerationPasscode(_ sender: UIButton) {
        self.completeSignUp(nil)
    }
}

extension InputAccountViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserPreference.currentUser.accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accountCell = tableView.dequeueReusableCell(withIdentifier: "AccountConfirmTableViewCell") as! AccountConfirmTableViewCell
        
        let account = UserPreference.currentUser.accounts[indexPath.row]
        accountCell.configureTableCell(account)
        
        return accountCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let account = UserPreference.currentUser.accounts[indexPath.row]
        if account.id == "" {
            self.showInputDialog(account.type)
        } else {
            self.showMessage("This Account has already confirmed.")
        }
    }
}

extension InputAccountViewController: RegistrationService {
    func userConfirmSuccess(_ account: String) {
        
        if isSaveAsDefault {
            AppManager.sharedInstance.saveDefaultOptionsToUserDefault(.accountId, detailOption: nil, accountId: account, purpose: "account")
        }
        
        self.enableGeneratePasscode()
        self.isSaveAsDefault = false
        self.tableView.reloadData()
        self.showToast("Account Confirmed Successfully")
    }
    
    func userConfirmFailed() {
        self.isSaveAsDefault = false
    }
}

extension InputAccountViewController: ConfirmAccountDialogControllerDelegate {
    func confirmAccount(_ id: AccountID, isDefault: Bool) {
        self.isSaveAsDefault = isDefault
        self.service?.confirmUser(id)
    }
}
