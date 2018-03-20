//
//  BaseNavViewController.swift
//  CurtisDigital
//
//  Created by mobilestar on 11/30/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit

class BaseNavViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.clipsToBounds = false
        self.navigationBar.layer.shadowColor = Colors.navigationBarTintColor.cgColor
        self.navigationBar.layer.shadowOpacity = 0.3
        self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.navigationBar.layer.shadowRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
