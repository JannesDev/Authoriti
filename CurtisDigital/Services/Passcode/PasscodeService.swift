
//
//  PasscodeService.swift
//  CurtisDigital
//
//  Created by mobilestar on 11/27/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import Alamofire

protocol PasscodeService: BaseService {

    func getSchemasSuccessfully()
    func getSchemasFailed()
    func getPurposeSuccessfully()
    func getPurposeFailed()
}

extension PasscodeService {
    
    func getSchemas() {
        
        AppManager.sharedInstance.loadSchemaFromUserDefault()
        
        if let connection = AppManager.sharedInstance.reachability?.connection, connection == .none {
            if AppManager.sharedInstance.schemas.count == 0 {
                self.showMessage("No internet connection. Please try again later.")
            } else {
                self.showToast("No internet connection.")
            }
            
            self.getSchemasFailed()
        } else {
           
            let endpoint = URLBuilder.urlGetSchema
            
            self.getUrl(endpoint, params: nil, headers: nil) { (response, error) in
                
                if let error = error {
                    if AppManager.sharedInstance.schemas.count == 0 {
                        self.showErrorMessage(error.localizedDescription)
                    } else {
//                        self.showToast(error.localizedDescription)
                    }
                    
                    self.getSchemasFailed()
                } else if let response = response {
                    print(response)
                    
                    AppManager.sharedInstance.saveSchemaToUserDefault(response)
                    self.getSchemasSuccessfully()
                }
            }
        }
    }
    
    func getPurpose() {
        AppManager.sharedInstance.loadPurposeFromUserDefault()
        
        if let connection = AppManager.sharedInstance.reachability?.connection, connection == .none {
            if AppManager.sharedInstance.schemas.count == 0 {
                self.showMessage("No internet connection. Please try again later.")
            } else {
                self.showToast("No internet connection.")
            }
            
            self.getSchemasFailed()
        } else {
            let endpoint = URLBuilder.urlGetPurpose
            
            do {
                var request = try URLRequest(url: endpoint.asURL())
                request.httpMethod = "GET"
                
                Alamofire.request(request).responseJSON(completionHandler: { (response) in
                    print(response)
                    switch response.result {
                    case .success(let data):
                        
                        if let data = data as? [[String: Any]] {
                            AppManager.sharedInstance.savePurposeToUserDefault(data)
                            self.getPurposeSuccessfully()
                        }
                        
                        break
                        
                    case .failure(let _):
                        self.getPurposeFailed()
                        break
                    }
                    
                })
            } catch(let error) {
                print(error)
                self.getPurposeFailed()
            }
        }
    }
}
