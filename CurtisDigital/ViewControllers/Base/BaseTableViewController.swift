//
//  BaseTableViewController.swift
//  CurtisDigital
//
//  Created by mobilestar on 11/18/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import MBProgressHUD
import SWRevealViewController
import MaterialComponents.MaterialSnackbar

class BaseTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.view.backgroundColor = Colors.backgroundViewColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showSideMenu(_ sender: Any) {
        self.revealViewController().revealToggle(animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
}

extension BaseTableViewController: BaseService {
    func wipeSuccess() {
        KeychainManager().clearAllData()
        UserPreference.currentUser.removeProfileFromUserDefault()
        UserAuth.removeUserAuthFromUserDefault()
        AppManager.sharedInstance.removeAllDefaultOptions()
        AppManager.sharedInstance.deleteSchemaFromUserDefault()
        AppManager.sharedInstance.deletePurposeFromUserDefault()
        
        UserAuth.logout()
        
        let storyboard = UIStoryboard(name: "Registration", bundle: nil)
        let inviteCode = storyboard.instantiateViewController(withIdentifier: "InviteCodeViewController")
        let navVC = BaseNavViewController(rootViewController: inviteCode)
        
        if let window = UIApplication.shared.delegate?.window {
            UIView.transition(with: window!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                let oldState: Bool = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(true)
                window?.rootViewController = navVC
                UIView.setAnimationsEnabled(oldState)
            }, completion: nil)
        }
    }
    
    func wipeFailed() {
        
    }
    
    func showToast(_ message: String) {
        let toast = MDCSnackbarMessage()
        toast.text = message
        toast.duration = 2.0
        MDCSnackbarManager.show(toast)
    }
    
    func showErrorMessage(_ message: String) {
        let windowAlertView = WindowAlertViewController(title: "ERROR!", message: message, preferredStyle: .alert)
        windowAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        windowAlertView.show()
    }
    
    func showErrorMessageWithRetry(_ message: String, retryAction: ((UIAlertAction) -> Void)?) {
        let windowAlertView = WindowAlertViewController(title: "ERROR!", message: message, preferredStyle: .alert)
        windowAlertView.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        windowAlertView.addAction(UIAlertAction(title: "Retry", style: .default, handler: retryAction))
        windowAlertView.show()
    }
    
    func showMessage(_ message: String) {
        let windowAlertView = WindowAlertViewController(title: "", message: message, preferredStyle: .alert)
        windowAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        windowAlertView.show()
    }
    
    func showAlert(_ title: String, message: String) {
        let windowAlertView = WindowAlertViewController(title: title, message: message, preferredStyle: .alert)
        windowAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        windowAlertView.show()
    }
    
    func showProgressHUD() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    func hideProgressHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func userLogoutSuccess() {
        UserAuth.logout()
        
        let storyboard = UIStoryboard(name: "Registration", bundle: nil)
        let navController = storyboard.instantiateViewController(withIdentifier: "UserAuthNavController")
        
        if let window = UIApplication.shared.delegate?.window {
            UIView.transition(with: window!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                let oldState: Bool = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(true)
                window?.rootViewController = navController
                UIView.setAnimationsEnabled(oldState)
            }, completion: nil)
        }
    }
}
