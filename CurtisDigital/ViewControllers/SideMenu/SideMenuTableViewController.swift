//
//  SideMenuTableViewController.swift
//  CurtisDigital
//
//  Created by mobilestar on 11/18/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit

enum SideMenu: Int {
    case permissionCode = 0
    case account
    case wipe
    case logout
}

class SideMenuTableViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoManageChaseAccountSegue" {
            let navVC = segue.destination as! BaseNavViewController
            let inputAccountVC = navVC.viewControllers.first as! InputAccountViewController
            inputAccountVC.isSignUp = false
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = SideMenu(rawValue: indexPath.row) else {
            return
        }
        switch item {
        case .account:
            if UserAuth.isChaseAccount {
                self.performSegue(withIdentifier: "GoManageChaseAccountSegue", sender: nil)
            } else {
                self.performSegue(withIdentifier: "GoManageAccountSegue", sender: nil)
            }
            break
        case .logout:
            self.userLogoutSuccess()
            break
        case .wipe:
            self.performSegue(withIdentifier: "goWipeSegue", sender: nil)
            break
        case .permissionCode:
            self.performSegue(withIdentifier: "GoMainSegue", sender: nil)
            break
        }
    }
}
