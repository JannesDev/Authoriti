//
//  AddProfileViewController.swift
//  CurtisDigital
//
//  Created by Jannes on 11/14/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit

class WipeViewController: BaseViewController {

    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var btnWipe: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //First get the nsObject by defining as an optional anyObject
        let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let buildString = Bundle.main.infoDictionary?["CFBundleVersion"]
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = versionString as! String
        let build = buildString as! String
        
        self.lblVersion.text = "Version \(version).\(build)"
        
        let attribute = [
            NSAttributedStringKey.underlineStyle: 1,
            NSAttributedStringKey.underlineColor: Colors.CreatePasscode.titleLabelColor,
            NSAttributedStringKey.foregroundColor: Colors.CreatePasscode.titleLabelColor,
            NSAttributedStringKey.font: Fonts.textField.buttonFont!
            ] as [NSAttributedStringKey : Any]
        
        let attributeText = NSAttributedString(string: "WIPE", attributes: attribute)
        self.btnWipe.setAttributedTitle(attributeText, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func wipeAllData(_ sender: Any) {
        self.wipe()
    }
    
    @IBAction func goHelper(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let helpVC = storyboard.instantiateViewController(withIdentifier: "HelpViewController")
        let navigation = BaseNavViewController(rootViewController: helpVC)
        self.present(navigation, animated: true, completion: nil)
    }
}


