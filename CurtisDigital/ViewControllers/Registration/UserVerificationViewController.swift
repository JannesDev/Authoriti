//
//  UserVerificationViewController.swift
//  CurtisDigital
//
//  Created by Jannes on 11/14/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import MaterialComponents

class UserVerificationViewController: BaseViewController {
    
    @IBOutlet weak var frontCardImageView: UIImageView!
    @IBOutlet weak var backCardImageView: UIImageView!
    @IBOutlet weak var frontImageViewLabel: UILabel!
    @IBOutlet weak var backImageViewLabel: UILabel!
    @IBOutlet weak var frontCameraIcon: UIImageView!
    @IBOutlet weak var backCameraIcon: UIImageView!
    @IBOutlet weak var btnVerify: MDCRaisedButton!
    
    var acuantInstance: AcuantMobileSDKController!
    let cardType: AcuantCardType = AcuantCardTypeDriversLicenseCard
    let cardRegion: AcuantCardRegion = AcuantCardRegionUnitedStates
    var cardSide: Int! // 0 front , 1 back
    var faceImage:NSData?

    var isSkip: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resetUI()
        resetData()
        setUpAcuantMobileSDK()
        
    }
    
    func resetUI(){
        frontCardImageView.image = nil
        frontImageViewLabel.isHidden = false
        
        backCardImageView.image = nil
        backImageViewLabel.isHidden = false
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func resetData(){
        faceImage = nil
        self.isSkip = false
    }
    
    func setUpAcuantMobileSDK() {
        showProgressHUD()
        acuantInstance = AcuantMobileSDKController.initAcuantMobileSDK(withLicenseKey: Constant.Keys.AcuantLicenseKey, andDelegate: self)
        cardSide = 0
    }
    
    // Show camera
    func showCamera() {
        if(acuantInstance.isAssureIDAllowed()){
            acuantInstance.setWidth(2024)
        }else{
            acuantInstance.setWidth(1250)
        }
        
        acuantInstance.showManualCameraInterface(in: self, delegate: self, cardType: cardType, region: cardRegion, andBackSide: true)
    }
    
    //Facial flow
    func captureSelfie(){
        self.showSelfiCaptureInterface()
        self.showToast("Hey you passed the drivers license validation, now we need to get a selfie... and then wait 5 sec.. then just go to selfie capture")
    }
    
    //Facial capture
    func showSelfiCaptureInterface(){
        let screenRect : CGRect = UIScreen.main.bounds
        let screenWidth : CGFloat = screenRect.size.width
        var messageFrame : CGRect = CGRect(x:0,y:50,width:screenWidth,height:20)
        
        let message : NSMutableAttributedString = NSMutableAttributedString.init(string: "Get closer until Red Rectangle appears and Blink")
        message.addAttribute(NSAttributedStringKey.foregroundColor, value:UIColor.white, range: NSMakeRange(0, message.length))
        let range : NSRange = NSMakeRange(17,13)
        let font : UIFont =  UIFont.systemFont(ofSize: 13)
        let boldFont : UIFont = UIFont.boldSystemFont(ofSize: 14)
        
        message.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: range)
        message.addAttribute(NSAttributedStringKey.font,value:font, range: NSMakeRange(0, message.length))
        message.addAttribute(NSAttributedStringKey.font,value:boldFont, range: range)
        
        let orientation : UIDeviceOrientation = UIDevice.current.orientation
        if(UIDeviceOrientationIsLandscape(orientation)){
            let screenHeight  : CGFloat = screenRect.size.height
            messageFrame = CGRect(x:0,y:50,width:screenHeight,height:20)
            
        }
        
        AcuantFacialRecognitionViewController.presentFacialCaptureInterface(with: self, withSDK: acuantInstance, in: self, withCancelButton: true, withCancelButtonRect: CGRect.init(x: 0, y: 20, width: 120, height: 50), withWaterMark: "Powered by Authoriti", withBlinkMessage: message, in: messageFrame)
    }
    
    func processCard() {
        let errorMessage : String = validateState()
        if (errorMessage == ""){
            
            let options : AcuantCardProcessRequestOptions  = AcuantCardProcessRequestOptions.defaultRequestOptions(for: cardType)

            //Optionally, configure the options to the desired value
            options.autoDetectState = true
            options.stateID = -1
            options.reformatImage = true
            options.reformatImageColor = 0
            options.dpi = Int32(150.0)
            options.cropImage = false
            options.faceDetection = true
            options.signatureDetection = false
            options.region = self.cardRegion

            showProgressHUD()
            acuantInstance.processFrontCardImage(frontCardImageView.image, backCardImage: backCardImageView.image, andStringData: nil, with: self, with: options)
        } else {
            self.showToast(errorMessage)
        }
    }
    
    //Data validation
    func validateState() -> String {
        var retValue : String!
        retValue = ""
        if(frontCardImageView.image == nil){
            retValue = "Please provide a front image"
        }else if(backCardImageView.image == nil){
            retValue = "Please provide a back image"
        }
        
        return retValue
    }
    
    func validateDLCardData(data: AcuantDriversLicenseCard) {
        // logging
        guard let frontImage = frontCardImageView.image, let backImage = backCardImageView.image else {
            return
        }
        
        self.logService?.logWith("DL authentication", metadata: self.parseAcuantDLResult(data: data), frontImage: frontImage, backImage: backImage)
        
        if data.authenticationResult == "Passed" {
            // go to selfie
            self.captureSelfie()
        } else {
            self.showToast("Could not verify your Driver's License. Please try again")
        }
    }
    
    func validateFaicalData(data: AcuantFacialData) {
        // logging
        guard let frontImage = frontCardImageView.image, let backImage = backCardImageView.image else {
            return
        }
        
        self.logService?.logWith("Selfie authentication", metadata: self.parseAcuantFaicialResult(data: data), frontImage: frontImage, backImage: backImage)
        
        if data.isMatch {
            self.goAccountManager()
        } else {
            self.showToast("Could not verify your Selfie image. Please try again")
        }
    }
    
    func parseAcuantDLResult(data: AcuantDriversLicenseCard) -> String {
        var dataArray:[String]! = Array()
        let separator = "  -  "
        if(data.authenticationResult == nil){
            data.authenticationResult = ""
        }
        dataArray.append("Authentication Result" + separator + data.authenticationResult)
        dataArray.append("First Name" + separator + data.nameFirst)
        dataArray.append("Middle Name" + separator + data.nameMiddle)
        dataArray.append("Last Name" + separator + data.nameLast)
        dataArray.append("Name Suffix" + separator + data.nameSuffix)
        dataArray.append("ID" + separator + data.licenceId)
        dataArray.append("License" + separator + data.license)
        dataArray.append("DOB Long" + separator + data.dateOfBirth4)
        dataArray.append("DOB Short" + separator + data.dateOfBirth)
        dataArray.append(            "Date Of Birth Local" + separator + data.dateOfBirthLocal)
        dataArray.append(            "Issue Date Long" + separator + data.issueDate4)
        dataArray.append(            "Issue Date Short" + separator + data.issueDate)
        dataArray.append(            "Issue Date Local" + separator + data.issueDateLocal)
        dataArray.append(            "Expiration Date Long" + separator + data.expirationDate4)
        dataArray.append(            "Expiration Date Short" + separator + data.expirationDate)
        dataArray.append(            "Eye Color" + separator + data.eyeColor)
        dataArray.append(            "Hair Color" + separator + data.hairColor)
        dataArray.append(            "Height" + separator + data.height)
        dataArray.append(            "Weight" + separator + data.weight)
        dataArray.append(            "Address" + separator + data.address)
        dataArray.append(            "Address 2" + separator + data.address2)
        dataArray.append(            "Address 3" + separator + data.address3)
        dataArray.append("Address 4" + separator + data.address4)
        dataArray.append("Address 5" + separator + data.address5)
        dataArray.append("Address 6" + separator + data.address6)
        dataArray.append("City" + separator + data.city)
        dataArray.append("Zip" + separator + data.zip)
        dataArray.append("State" + separator + data.state)
        dataArray.append("County" + separator + data.county)
        dataArray.append("Country Short" + separator + data.countryShort)
        dataArray.append("Country Long" + separator + data.idCountry)
        dataArray.append("Class" + separator + data.licenceClass)
        dataArray.append("Restriction" + separator + data.restriction)
        dataArray.append("Sex" + separator + data.sex)
        dataArray.append("Audit" + separator + data.audit)
        dataArray.append("Endorsements" + separator + data.endorsements)
        dataArray.append("Fee" + separator + data.fee)
        dataArray.append("CSC" + separator + data.csc)
        dataArray.append("SigNum" + separator + data.sigNum)
        dataArray.append("Text1" + separator + data.text1)
        dataArray.append("Text2" + separator + data.text2)
        dataArray.append("Text3" + separator + data.text3)
        dataArray.append("Type" + separator + data.type)
        dataArray.append("Doc Type" + separator + data.docType)
        dataArray.append("Father Name" + separator + data.fatherName)
        dataArray.append("Mother Name" + separator + data.motherName)
        dataArray.append("NameFirst_NonMRZ" + separator + data.nameFirst_NonMRZ)
        dataArray.append("NameLast_NonMRZ" + separator + data.nameLast_NonMRZ)
        dataArray.append("NameLast1" + separator + data.nameLast1)
        dataArray.append("NameLast2" + separator + data.nameLast2)
        dataArray.append("NameMiddle_NonMRZ" + separator + data.nameMiddle_NonMRZ)
        dataArray.append("NameSuffix_NonMRZ" + separator + data.nameSuffix_NonMRZ)
        dataArray.append("Document Detected Name" + separator + data.documentDetectedName)
        dataArray.append("Document Detected Name Short" + separator + data.documentDetectedNameShort)
        dataArray.append("Nationality" + separator + data.nationality)
        dataArray.append("Original" + separator + data.original)
        dataArray.append("PlaceOfBirth" + separator + data.placeOfBirth)
        dataArray.append("PlaceOfIssue" + separator + data.placeOfIssue)
        dataArray.append("Social Security" + separator + data.socialSecurity)
        dataArray.append("TID" + separator + data.transactionId)
        
        return dataArray.joined(separator: ",")
    }
    
    func parseAcuantFaicialResult(data: AcuantFacialData) -> String {
        var dataArray:[String]! = Array()
        let separator = "  -  "
        
        dataArray.append("faceLivelinessDetection" + separator + String(data.faceLivelinessDetection));
        dataArray.append("Face Matched" + separator + String(data.isMatch));
        dataArray.append("facialMatchConfidenceRating" + separator + String(data.facialMatchConfidenceRating));
        dataArray.append("FTID" + separator + data.transactionId);
        
        return dataArray.joined(separator: ",")
    }
    
    // Go Account Manager Screen
    @objc func goAccountManager() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let accountManageVC = storyboard.instantiateViewController(withIdentifier: "ManageAccountViewController") as! ManageAccountViewController
        accountManageVC.isSignUp = true
        
        let userProfile = UserPreference.currentUser
        userProfile.removeAccounts()
        UserAuth.setIsChaseAccount(false)
        
        self.navigationController?.pushViewController(accountManageVC, animated: true)
    }
    
    // MARK: @IBActions
    
    @IBAction func skipDL(_ sender: Any) {
        self.isSkip = true
//        self.captureSelfie()
        self.goAccountManager()
    }
    
    @IBAction func onFrontImagePressed(_ sender: Any) {
        print("front image tapped")
        cardSide = 0
        showCamera()
    }
    
    @IBAction func onBackImagePressed(_ sender: Any) {
        print("back image tapped")
        cardSide = 1
        showCamera()
    }
    
    @IBAction func onVerifyPressed(_ sender: Any) {
        processCard()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserVerificationResultSegue"{
            let destinationVC :UserVerificationResultViewController = segue.destination as! UserVerificationResultViewController
            destinationVC.cardType=cardType
            destinationVC.region=cardRegion
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UserVerificationViewController: AcuantMobileSDKControllerCapturingDelegate {
    
    func imageForHelpImageView() -> UIImage! {
        let image = UIImage(named:"PDF417.png")
        return image
    }
    
    func mobileSDKWasValidated(_ wasValidated: Bool) {
        hideProgressHUD()
        if(wasValidated){
            print("valid license key")
        }else{
            showToast("License key is not valid")
        }
    }
    
    func showBackButton() -> Bool {
        return true
    }
    
    func didCaptureCropImage(_ cardImage: UIImage!, scanBackSide: Bool, andCardType cardType: AcuantCardType, withImageMetrics imageMetrics: [AnyHashable : Any]!) {
        print("didCaptureCropImage")
        if(cardSide == 0) {
            frontImageViewLabel.isHidden = true
            frontCardImageView.image = cardImage
        } else if(cardSide == 1) {
            backImageViewLabel.isHidden = true
            backCardImageView.image = cardImage
        }
        
        if self.validateState() == "" {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func didCaptureData(_ data: String!) {
        print("didCaptureData")
    }
    
    func didFailToCaptureCropImage() {
        
    }
}

extension UserVerificationViewController: AcuantMobileSDKControllerProcessingDelegate {
    func didFinishValidatingImage(with result: AcuantCardResult!) {
        if((result as? AcuantFacialData) != nil){
            print("facial completed")
            hideProgressHUD()
            self.validateFaicalData(data: result as! AcuantFacialData)
        }
    }
    
    func didFinishProcessingCard(with result: AcuantCardResult!) {
        hideProgressHUD()
        let data : AcuantDriversLicenseCard = result as! AcuantDriversLicenseCard;
        faceImage = data.faceImage as? NSData;
        self.validateDLCardData(data: data)
    }
    
    func didFailProcessingAssureIDWithError(_ error: AcuantError!) {
        print("Error -", error.errorType)
        print("Error -", error.errorMessage)
    }
}

extension UserVerificationViewController: AcuantFacialCaptureDelegate {
    func didFinishFacialRecognition(_ image: UIImage!) {
        if isSkip {
            self.showToast("Selfie Validation Suceessfully.")
            self.perform(#selector(self.goAccountManager), with: nil, afterDelay: 1.0)
            return
        }
        
        guard let faceImage = self.faceImage else {
            showToast("Cannot get face image from DL")
            return
        }
        
        DispatchQueue.global(qos: .background).async{
            DispatchQueue.main.async{
                //Selfie Image
                let frontSideImage :UIImage = image
                //DL Photo
                let dlPhoto : NSData = faceImage
                
                //Obtain the default AcuantCardProcessRequestOptions object for the type of card you want to process (License card for this example)
                let options : AcuantCardProcessRequestOptions = AcuantCardProcessRequestOptions.defaultRequestOptions(for: AcuantCardTypeFacial)
                
                // Now, perform the request
                self.showProgressHUD()
                self.acuantInstance.validatePhotoOne(frontSideImage, withImage: dlPhoto as Data!, with: self, with: options)
            }
        }
    }
    
    func didCancelFacialRecognition() {
        self.showToast("Selfie recognition is timeouted, try again")
    }
    
    func didTimeoutFacialRecognition(_ lastImage: UIImage!) {
        
    }
    
    func imageForFacialBackButton() -> UIImage! {
        return nil
    }
    
    func facialRecognitionTimeout() -> Int32 {
        return 20
    }
    
    func shouldShowFacialTimeoutAlert() -> Bool {
        return false
    }
    
    func messageToBeShownAfterFaceRectangleAppears() -> NSAttributedString! {
        return nil
    }
    
    func frameWhereMessageToBeShownAfterFaceRectangleAppears() -> CGRect {
        return CGRect.zero
    }
    
    func didFailWithError(_ error: AcuantError!) {
        hideProgressHUD()
        // self.showErrorMessage(error.errorMessage)
        self.showToast(error.errorMessage)
    }
    
}
