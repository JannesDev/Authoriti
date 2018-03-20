//
//  WindowAlertViewController.swift
//  Cambi
//
//  Created by Janness on 3/20/16.
//  Copyright © 2016 Marks. All rights reserved.
//

import UIKit

open class WindowAlertViewController: UIAlertController {

	fileprivate lazy var alertWindow: UIWindow = {

		let window = UIWindow(frame: UIScreen.main.bounds)
		window.rootViewController = WindowClearViewController()
		window.backgroundColor = UIColor.clear
		return window
	}()

	open func show(animate flag: Bool = true, completion: (() -> Void)? = nil) {
		if let rootViewController = alertWindow.rootViewController {
			alertWindow.makeKeyAndVisible()

			rootViewController.present(self, animated: flag, completion: completion)
		}
	}

	open func dismiss(animate flag: Bool = true, completion: (() -> Void)? = nil) {
		self.dismiss(animated: flag, completion: completion)
	}

	deinit {
		alertWindow.isHidden = true
	}
}

private class WindowClearViewController: UIViewController {

	fileprivate override var preferredStatusBarStyle: UIStatusBarStyle {
		return UIApplication.shared.statusBarStyle
	}

	fileprivate override var prefersStatusBarHidden: Bool {
		return UIApplication.shared.isStatusBarHidden
	}
}
