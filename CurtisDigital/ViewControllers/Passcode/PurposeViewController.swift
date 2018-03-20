//
//  PurposeViewController.swift
//  CurtisDigital
//
//  Created by mobilestar on 2/27/18.
//  Copyright © 2018 Mark. All rights reserved.
//

import UIKit

class PurposeViewController: BaseViewController {

    var service: PasscodeService?
    
    @IBOutlet weak var tableView: UITableView!
    
    var purposeList: [Purpose] = [Purpose]()
    
    var selectedIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create an instance to generate a new passcode
        self.service = self
        self.reloadSchemas()
        
        self.setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadSchemas), name: NSNotification.Name(rawValue: "ReloadSchema"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    func setupViews() {
        self.revealViewController().rearViewRevealWidth = view.frame.size.width * 0.85
        self.revealViewController().tapGestureRecognizer()
        
        AppManager.sharedInstance.loadPurposeFromUserDefault()
        AppManager.sharedInstance.loadSchemaFromUserDefault()
        self.purposeList = AppManager.sharedInstance.purposes
        self.tableView.reloadData()
    }
    
    @IBAction func goHelper(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let helpVC = storyboard.instantiateViewController(withIdentifier: "HelpViewController")
        let navigation = BaseNavViewController(rootViewController: helpVC)
        self.present(navigation, animated: true, completion: nil)
    }
    
    @objc func reloadSchemas() {
        self.service?.getSchemas()
        self.service?.getPurpose()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoAddNewPicker" {
            let addNewPasscode = segue.destination as! AddNewPasscodeViewController
            addNewPasscode.purpose = self.purposeList[self.selectedIndex]
        }
    }
}

extension PurposeViewController: PasscodeService {
    func getPurposeSuccessfully() {
        self.purposeList = AppManager.sharedInstance.purposes
        self.tableView.reloadData()
    }
    
    func getPurposeFailed() {
        self.tableView.reloadData()
    }
    
    func getSchemasSuccessfully() {


    }
    
    func getSchemasFailed() {

    }
}

extension PurposeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.purposeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PurposeTableViewCell") as! PurposeTableViewCell
        
        cell.configureTableCell(purposeList[indexPath.row])
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        self.selectedIndex = indexPath.row
        
        self.performSegue(withIdentifier: "GoAddNewPicker", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
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

extension PurposeViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let saveAsDefault = SwipeAction(style: .default, title: "Save As Default") { (_, index) in
            let purpose = self.purposeList[index.row]
            purpose.savePurposeAsDefault()
            self.tableView.reloadData()
        }
        
        saveAsDefault.hidesWhenSelected = true
        saveAsDefault.backgroundColor = Colors.CreatePasscode.saveButtonColor
        
        return [saveAsDefault]
    }
}
