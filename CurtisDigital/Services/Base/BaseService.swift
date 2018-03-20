//
//  BaseService.swift
//  CurtisDigital
//
//  Created by Jannes on 11/14/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import Alamofire

@objc protocol BaseService: NSObjectProtocol {
    func showMessage(_ message: String)
    func showErrorMessage(_ message: String)
    func showProgressHUD()
    func hideProgressHUD()
    func userLogoutSuccess()
    func wipeSuccess()
    func wipeFailed()
    func showToast(_ message: String)
}

extension BaseService {
    
    func userLogout() {
        if let connection = AppManager.sharedInstance.reachability?.connection, connection == .none {
            self.userLogoutSuccess()
        } else {
            // Show Loading View
            self.showProgressHUD()
            
            let endpoint = URLBuilder.urlLogout
            let headers = [APIKeys.Login.keyAuthToken: "Bearer \(UserAuth.token)"]
            
            print("User Logout: endpoint - \(endpoint), headers - \(headers)")
            
            self.postUrl(endpoint, params: nil, headers: headers) { (response, error) in
                if let error = error {
                    self.showErrorMessage(error.localizedDescription)
                } else if let response = response {
                    print("\(response)")
                    self.userLogoutSuccess()
                }
            }
        }
    }
    
    func wipe() {
        self.wipeSuccess()
//        if let connection = AppManager.sharedInstance.reachability?.connection, connection == .none {
//            self.showErrorMessage("Connection Failed. Try again later")
//            self.wipeFailed()
//        } else {
//            // Show Loading View
//            self.showProgressHUD()
//
//            let endpoint = URLBuilder.urlWipe
//            let headers = [APIKeys.Header.keyAuthorization: "Bearer \(UserAuth.token)"]
//
//            print("User Logout: endpoint - \(endpoint), headers - \(headers)")
//
//            self.deleteUrl(endpoint, params: nil, headers: headers) { (response, error) in
//                if let error = error {
//                    self.showErrorMessage(error.localizedDescription)
//                } else if let response = response {
//                    print("\(response)")
//                    self.wipeSuccess()
//                }
//            }
//        }
    }
    
    func postUrl(_ url: URLConvertible, params: [String: Any]?, headers: [String: Any]?, completionBlock:(([String: AnyObject]?, NSError?) -> Void)?) {
        print("CALL:\(url)")
        print("PARAMS: \(params ?? [:])")
        print("HEADER: \(headers ?? [:])")
        
        do {
            var request = try URLRequest(url: url.asURL())
            request.httpMethod = "POST"
            
            if let params = params {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            }
            
            // Populating the header
            if let headers = headers {
                for (key, value) in headers {
                    request.setValue(value as? String, forHTTPHeaderField: key)
                }
            }
            
            Alamofire.request(request).responseJSON(completionHandler: { (response) in
                print(response)
                
                let (parsedResponse, parsedError) = self.parse(response)
                completionBlock?(parsedResponse, parsedError)
            })
        } catch(let error) {
            print(error)
            completionBlock?(nil, error as NSError)
        }
    }
    
    func putUrl(_ url: URLConvertible, params: [String: Any]?, headers: [String: Any]?, completionBlock:(([String: AnyObject]?, NSError?) -> Void)?) {
        print("CALL:\(url)")
        print("PARAMS: \(params ?? [:])")
        print("HEADER: \(headers ?? [:])")
        
        do {
            var request = try URLRequest(url: url.asURL())
            request.httpMethod = "PUT"
            
            if let params = params {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            }
            
            // Populating the header
            if let headers = headers {
                for (key, value) in headers {
                    request.setValue(value as? String, forHTTPHeaderField: key)
                }
            }
            
            Alamofire.request(request).responseJSON(completionHandler: { (response) in
                print(response)
                
                let (parsedResponse, parsedError) = self.parse(response)
                completionBlock?(parsedResponse, parsedError)
            })
        } catch(let error) {
            print(error)
            completionBlock?(nil, error as NSError)
        }
    }
    
    func getUrl(_ url: URLConvertible, params: [String: Any]?, headers: [String: Any]?, completionBlock:(([String: AnyObject]?, NSError?) -> Void)?) {
        print("CALL:\(url)")
        print("PARAMS: \(params ?? [:])")
        print("HEADER: \(headers ?? [:])")
        
        do {
            var request = try URLRequest(url: url.asURL())
            request.httpMethod = "GET"
            
            if let params = params {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            }
            
            // Populating the header
            if let headers = headers {
                for (key, value) in headers {
                    request.setValue(value as? String, forHTTPHeaderField: key)
                }
            }
            
            Alamofire.request(request).responseJSON(completionHandler: { (response) in
                print(response)
                
                let (parsedResponse, parsedError) = self.parse(response)
                completionBlock?(parsedResponse, parsedError)
            })
        } catch(let error) {
            print(error)
            completionBlock?(nil, error as NSError)
        }
    }
    
    func deleteUrl(_ url: URLConvertible, params: [String: Any]?, headers: [String: Any]?, completionBlock:(([String: AnyObject]?, NSError?) -> Void)?) {
        print("CALL:\(url)")
        print("PARAMS: \(params ?? [:])")
        print("HEADER: \(headers ?? [:])")
        
        do {
            var request = try URLRequest(url: url.asURL())
            request.httpMethod = "DELETE"
            
            if let params = params {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            }
            
            // Populating the header
            if let headers = headers {
                for (key, value) in headers {
                    request.setValue(value as? String, forHTTPHeaderField: key)
                }
            }
            
            Alamofire.request(request).responseJSON(completionHandler: { (response) in
                print(response)
                
                let (parsedResponse, parsedError) = self.parse(response)
                completionBlock?(parsedResponse, parsedError)
            })
        } catch(let error) {
            print(error)
            completionBlock?(nil, error as NSError)
        }
    }
    
    // MARK: - Parse Json Response
    func parse( _ response: DataResponse<Any>) -> ([String: AnyObject]?, NSError?) {
        guard let result = response.value else {
            guard let error = response.error else {
                return (response: nil, error: NSError(domain: AppErrorInfo.Domain, code: 500, userInfo: [AppErrorInfo.ErrorDescriptionKey: "error unpacking response"]))
            }
            print ("error: \(error)")
            let nserror = error as NSError
            if  nserror.domain == NSURLErrorDomain {
                let code = nserror.code
                if code < -1000 {
                    let message = "No Internet Connection."
                    return(nil, NSError(domain: AppErrorInfo.Domain, code: 500, userInfo: ["message": message]))
                } else if code == 1001 {
                    let message = "The request timed out."
                    return(nil, NSError(domain: AppErrorInfo.Domain, code: 500, userInfo: ["message": message]))
                }
                
                return (response: nil, error: nserror)
            }
            
            return (response: nil, error: NSError(domain: AppErrorInfo.Domain, code: 500, userInfo: [AppErrorInfo.ErrorDescriptionKey: "error unpacking response"]))
        }
        
        let error = response.error
       
        guard let json = result as? [String: AnyObject] else {
            var userInfo: [String:Any] = [AppErrorInfo.ErrorDescriptionKey: ""]
            if let errVal = error {
                userInfo[AppErrorInfo.ErrorKey] = errVal
            }
            
            return (response: nil, error: NSError(domain: AppErrorInfo.Domain, code: 500, userInfo: userInfo))
        }
        
        return(json, error: nil)
    }
}
