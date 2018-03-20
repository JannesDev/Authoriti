//
//  LogService.swift
//  CurtisDigital
//
//  Created by Brian on 2017-11-22.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import SwiftDate
import Alamofire

protocol LogService: BaseService {
    func userLogSuccess()
    func userLogFailed()
}

extension LogService {
    
    func logWith(_ event: String, metadata: String, frontImage: UIImage, backImage: UIImage) {
        
        //Show Loading View
        self.showProgressHUD()
        
        let endpoint = URLBuilder.urlLog
        let eventDic = [
            APIKeys.Log.keyEvent        : event,
            APIKeys.Log.keyTime         : DateInRegion().string(format: .iso8601(options: [.withInternetDateTime])),
            APIKeys.Log.keyMetaData     : metadata
        ]
        
        let events = [eventDic]
        
        let params = [
            APIKeys.Log.keyEvents               : events,
            APIKeys.Log.keyToken                : ""
        ] as [String : Any]
        
        print("User Log: endpoint - \(endpoint), params - \(params)")
        
        let data = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        print(data)
        
        guard let frontData = UIImageJPEGRepresentation(frontImage, 0.1) else {
            self.showMessage("Front Image cannot found.")
            return
        }
        
        guard let backData = UIImageJPEGRepresentation(backImage, 0.1) else {
            self.showMessage("Back Image cannot found.")
            return
        }
        
        Alamofire.upload(multipartFormData: { (formData) in

            formData.append(frontData, withName: "front", fileName: "front.jpg", mimeType: "image/jpeg")
            formData.append(backData, withName: "back", fileName: "back.jpg", mimeType: "image/jpeg")
            formData.append(data, withName: APIKeys.Log.keyLog)

            print(formData)

        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold * 10, to: endpoint, method: .post, headers: nil) { (result) in

            print(result)

            switch result {
            case .success(request: let _request, streamingFromDisk: _, streamFileURL: _):

                print(_request)

                _request.responseString(completionHandler: { (response) in
                    self.hideProgressHUD()

                    print(response)
                    
                    switch response.result {
                    case .success(let value):
                        print(value)
                        self.userLogSuccess()
                        break
                    case .failure(let error):
                        print(error.localizedDescription)
                        self.userLogFailed()
                        break
                    }
                })
                break
            case .failure(let error):
                self.hideProgressHUD()
                self.showErrorMessage(error.localizedDescription)
                print(error.localizedDescription)
                break
            }
        }
    }
}

