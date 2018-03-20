//
//  CommonUtil.swift
//  CurtisDigital
//
//  Created by Jannes on 11/15/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import CoreLocation

class CommonUtil: NSObject {

    class func validatedEmail(_ email: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    public static func getHeightFromString(_ string: String, width: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = string.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return boundingBox.height
    }
    
    public static func locationToLocality(_ location: CLLocation, completionBlock: @escaping ((CLPlacemark) -> Void)) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Error Found: %@", error.localizedDescription)
            } else if let placemarks = placemarks, placemarks.count > 0 {
                if let placemark = placemarks.last {
                    completionBlock(placemark)
                }
            }
        }
    }
    
    public static func getCountries() -> [String] {
        let filePath = Bundle.main.path(forResource: "country", ofType: "json")
        var countryNames = [String]()
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath!))
            let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
            if let countryObject = jsonData["countryCodes"] as? [[String: Any]], countryObject.count > 0 {
                countryNames = countryObject.map({ (country) -> String in
                    return country["country_name"] as? String ?? ""
                })
            }
        } catch (let error) {
            print(error.localizedDescription)
        }
        
        return countryNames
    }
}
