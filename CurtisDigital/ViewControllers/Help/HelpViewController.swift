//
//  HelpViewController.swift
//  CurtisDigital
//
//  Created by mobilestar on 1/23/18.
//  Copyright © 2018 Mark. All rights reserved.
//

import UIKit

class HelpViewController: BaseViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       self.setupViews()
    }
    
    func setupViews() {
        self.showProgressHUD()
        
        let helpUrl = URLBuilder.urlHelper
        let urlRequest = URLRequest(url: URL(string: helpUrl)!)
        self.webView.loadRequest(urlRequest)
    }
    
    // MARK: - Actions
    @IBAction func dismiss(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

extension HelpViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("webViewDidStartLoad")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("webViewDidFinishLoad")
        
        self.hideProgressHUD()
    }
}
