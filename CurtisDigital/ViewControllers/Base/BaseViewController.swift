//
//  BaseViewController.swift
//  CurtisDigital
//
//  Created by Jannes on 11/14/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import MBProgressHUD
import SWRevealViewController
import MaterialComponents.MaterialSnackbar

class BaseViewController: UIViewController {
    
    var hideNavigationBar: Bool!
    var logService: LogService?
    
    @IBOutlet weak var nextBottomConstraint: NSLayoutConstraint!
    
    var errorMessage: String = "" {
        didSet {
            showErrorMessage(errorMessage)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hideNavigationBar = false
        self.logService = self
        self.view.backgroundColor = Colors.backgroundViewColor
        
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name: "Oswald-Regular", size: 18.0)
        titleLabel.text = "AUTHORITI"
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = self.hideNavigationBar
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeKeyboardFrame(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboardFrame(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didHideKeyboardFrame(_:)), name: Notification.Name.UIKeyboardDidHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //AppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
        // Don't forget to reset when view is being removed
        //AppUtility.lockOrientation(.all)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notifications
    
    @objc func willHideKeyboardFrame(_ notification: Notification) {
        guard let constraint = self.nextBottomConstraint else {
            return
        }
        
        constraint.constant = 0
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: UIViewKeyframeAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func didHideKeyboardFrame(_ notification: Notification) {
        
    }
    
    @objc func didChangeKeyboardFrame(_ notification: Notification) {
        guard let constraint = self.nextBottomConstraint else {
            return
        }
        
        let userinfo = notification.userInfo ?? [:]
        let keyboardFrame = (userinfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        constraint.constant = keyboardFrame.size.height
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: UIViewKeyframeAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func showSideMenu(_ sender: Any) {
        self.revealViewController().revealToggle(animated: true)
    }
    
    @IBAction func dismissViewController(_ sender: Any) {
        if let navVC = self.navigationController {
            navVC.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension BaseViewController: BaseService {
    
    func showErrorMessage(_ message: String) {
        let windowAlertView = WindowAlertViewController(title: "Oops!", message: message, preferredStyle: .alert)
        windowAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        windowAlertView.show()
    }
    
    func showErrorMessageWithRetry(_ message: String, retryAction: ((UIAlertAction) -> Void)?) {
        let windowAlertView = WindowAlertViewController(title: "Oops!", message: message, preferredStyle: .alert)
        windowAlertView.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        windowAlertView.addAction(UIAlertAction(title: "Retry", style: .default, handler: retryAction))
        windowAlertView.show()
    }
    
    func showMessage(_ message: String) {
        let windowAlertView = WindowAlertViewController(title: "", message: message, preferredStyle: .alert)
        windowAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        windowAlertView.show()
    }
    
    func showAlert(_ title: String, message: String, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        let windowAlertView = WindowAlertViewController(title: title, message: message, preferredStyle: .alert)
        windowAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        windowAlertView.show()
    }
    
    func showProgressHUD() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    func hideProgressHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func wipeSuccess() {
        KeychainManager().clearAllData()
        UserPreference.currentUser.removeProfileFromUserDefault()
        UserAuth.removeUserAuthFromUserDefault()
        AppManager.sharedInstance.deleteSchemaFromUserDefault()
        AppManager.sharedInstance.removeAllDefaultOptions()
        
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
    
    func showToast(_ message: String) {
        let toast = MDCSnackbarMessage()
        toast.text = message
        toast.duration = 2.0
        MDCSnackbarManager.show(toast)
    }
}

extension BaseViewController: LogService {
    
    func userLogSuccess() {
        print("Log Success")
    }
    
    func userLogFailed() {
        print("Log Failed")
    }
}
