//
//  ManageAccountViewController.swift
//  CurtisDigital
//
//  Created by mobilestar on 11/21/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import MaterialComponents
import DropDown
import SwiftValidator
import BEMCheckBox
import BiometricAuthentication

class ManageAccountViewController: BaseViewController {

    var isSignUp: Bool = false
    var isSaveAsDefault: Bool = false
    var signupService: RegistrationService?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var generatePasscode: MDCRaisedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.signupService = self
        
        self.setupNavItems()
        self.setupViews()
        self.enableGeneratePasscode()
    }

    func setupNavItems() {
        if !isSignUp {
            let leftMenuItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_menu"), style: .plain, target: self, action: #selector(showSideMenu(_:)))
            navigationItem.leftBarButtonItem = leftMenuItem
            
        } else {            
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }
    
    func setupViews() {
        self.tableView.register(UINib.init(nibName: "ManageAccountTableViewCell", bundle: nil), forCellReuseIdentifier: "ManageAccountTableViewCell")
    }
    
    private func goMyPasscodes() {
        UserAuth.setLastTime()
        UserAuth.setIsLoggedIn(true)
        AppManager.sharedInstance.deleteSchemaFromUserDefault()
        AppManager.sharedInstance.removeAllDefaultOptions()
        
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
        if isSignUp, UserPreference.currentUser.accounts.count == 0 {
            self.generatePasscode.isEnabled = false
        } else {
            self.generatePasscode.isEnabled = true
        }
    }
    
    func showEnableTouchId() {
        
        if !BioMetricAuthenticator.shared.faceIDAvailable() {
            let alertControl = UIAlertController(title: "Please go to Touch ID and Passcode on Device Settings and enroll your fingerprint.", message: nil, preferredStyle: .alert)
            let dontAllow = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let allow = UIAlertAction(title: "Go Setting", style: .default, handler: { (_) in
                let url = URL(string: "App-Prefs:root=TOUCHID_PASSCODE")
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
            })
            
            alertControl.addAction(dontAllow)
            alertControl.addAction(allow)
            
            self.present(alertControl, animated: true, completion: nil)
        } else {
            let alertControl = UIAlertController(title: "Please go to Device Face ID and Passcode on Device Settings and enroll your face.", message: nil, preferredStyle: .alert)
            let dontAllow = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let allow = UIAlertAction(title: "Go Setting", style: .default, handler: { (_) in
                let url = URL(string: "App-Prefs:root=FACEID_PASSCODE")
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
            })
            
            alertControl.addAction(dontAllow)
            alertControl.addAction(allow)
            
            self.present(alertControl, animated: true, completion: nil)
        }
    }
    
    // MARK: - IBAction
    @IBAction func completeSignUp(_ sender: Any?) {
        self.signupService?.userSignUpWith()
    }
    
    @IBAction func addAccount(_ sender: Any) {
        
        let dialogController = MDCDialogTransitionController()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let inputDialog = storyboard.instantiateViewController(withIdentifier: "InputAccountDialogController") as! InputAccountDialogController
        inputDialog.delegate = self
        inputDialog.modalPresentationStyle = .overFullScreen
        inputDialog.modalTransitionStyle = .crossDissolve
        inputDialog.transitioningDelegate = dialogController
        
        self.present(inputDialog, animated: true, completion: nil)
    }
    
    @IBAction func goGenerationPasscode(_ sender: UIButton) {
        if isSignUp {
            self.completeSignUp(nil)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navController = storyboard.instantiateViewController(withIdentifier: "MainNavController")
            
            if let window = UIApplication.shared.delegate?.window {
                UIView.transition(with: window!, duration: 0.5, options: .transitionFlipFromRight, animations: {
                    let oldState: Bool = UIView.areAnimationsEnabled
                    UIView.setAnimationsEnabled(true)
                    window?.rootViewController = navController
                    UIView.setAnimationsEnabled(oldState)
                }, completion: nil)
            }
        }
    }
    
    @IBAction func signInWithFingerPrint(_ sender: Any?) {
        print(BioMetricAuthenticator.canAuthenticate())
        let keyChain = KeychainManager()
        if let _ = keyChain.getDataFromKeychain(Constant.Keys.keyPassword), let _ = keyChain.getDataFromKeychain(Constant.Keys.keyPrivate), UserAuth.token != "" {
            
            var detectFace = ""
            if BioMetricAuthenticator.shared.faceIDAvailable() {
                detectFace = "Face"
            } else {
                detectFace = "Touch"
            }
            
            let alertControl = UIAlertController(title: "Do you want to allow Authoriti to use \(detectFace) ID?", message: nil, preferredStyle: .alert)
            let dontAllow = UIAlertAction(title: "Don't allow", style: .cancel, handler: { (_) in
                UserAuth.setIsTouchId(false)
                self.goMyPasscodes()
            })
            
            let allow = UIAlertAction(title: "Allow", style: .default, handler: { (_) in
                if BioMetricAuthenticator.canAuthenticate() {
                    UserAuth.setIsTouchId(true)
                    self.goMyPasscodes()
                } else {
                    self.showEnableTouchId()
                }
            })
            
            alertControl.addAction(dontAllow)
            alertControl.addAction(allow)
            
            self.present(alertControl, animated: true, completion: nil)
        }
    }
}

extension ManageAccountViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserPreference.currentUser.accounts.count > 0 {
            return UserPreference.currentUser.accounts.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if UserPreference.currentUser.accounts.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoAccountsCell")
            return cell!
        }
        
        let accountCell = tableView.dequeueReusableCell(withIdentifier: "ManageAccountTableViewCell") as! ManageAccountTableViewCell
        
        accountCell.configureTableCell(UserPreference.currentUser.accounts[indexPath.row])
        
        return accountCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if UserPreference.currentUser.accounts.count > 1 {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, index) in
            UserPreference.currentUser.accounts.remove(at: index.row)
            UserPreference.currentUser.saveProfileToUserDefault()
            self.tableView.reloadData()
        }
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UserPreference.currentUser.accounts.count == 0 {
            return 100
        } else {
            return 44.0
        }
    }
}

extension ManageAccountViewController: InputAccountDialogControllerDelegate {
    func createNewAccount(_ account: AccountID, isDefault: Bool) {
        let matchedAccounts = UserPreference.currentUser.accounts.filter({$0.id == account.id || $0.type == account.type})
        if matchedAccounts.count > 0 {
            self.showErrorMessage("This accountID is already existed.")
            return
        }
        
        if !isSignUp {
            self.signupService?.updateUser(account)
            self.isSaveAsDefault = isDefault
        } else {
            UserPreference.currentUser.accounts.append(account)
            
            if isDefault {
                AppManager.sharedInstance.saveDefaultOptionsToUserDefault(.accountId, detailOption: nil, accountId: account.id, purpose: "account")
            }
            
            self.tableView.reloadData()
            self.enableGeneratePasscode()
        }
    }
}

extension ManageAccountViewController: RegistrationService {
    func userUpdateInfoSuccess(_ response: [String : Any]) {
        if isSaveAsDefault {
            AppManager.sharedInstance.saveDefaultOptionsToUserDefault(.accountId, detailOption: nil, accountId: UserPreference.currentUser.accounts.last!.id, purpose: "account")
            self.isSaveAsDefault = false
        }
        
        self.tableView.reloadData()
        self.enableGeneratePasscode()
    }
    
    func userUpdateInfoFailed() {
        self.enableGeneratePasscode()
    }
    
    func userSignUpSuccess(_ response: [String : Any]) {
        self.signInWithFingerPrint(nil)
    }
    
    func userSignUpFailed() {
        
    }
}
