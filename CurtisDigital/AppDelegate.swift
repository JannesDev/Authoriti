//
//  AppDelegate.swift
//  CurtisDigital
//
//  Created by Jannes on 11/14/17.
//  Copyright © 2017 Mark. All rights reserved.
//

import UIKit
import CoreLocation
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var orientationLock = UIInterfaceOrientationMask.all
    
    let locationManager: CLLocationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UINavigationBar.appearance().barTintColor = Colors.navigationBarTintColor
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        let _ = AppManager.sharedInstance
        if UserPreference.currentUser.accounts.count == 0 {
            let storyboard = UIStoryboard(name: "Registration", bundle: nil)
            let inviteCode = storyboard.instantiateViewController(withIdentifier: "InviteCodeViewController")
            let navVC = BaseNavViewController(rootViewController: inviteCode)
            self.window?.rootViewController = navVC
        } else if UserAuth.needLogin {
            let storyboard = UIStoryboard(name: "Registration", bundle: nil)
            let navController = storyboard.instantiateViewController(withIdentifier: "UserAuthNavController")
            self.window?.rootViewController = navController
            
        } else if UserAuth.isLoggedin == false {
            let storyboard = UIStoryboard(name: "Registration", bundle: nil)
            let navController = storyboard.instantiateViewController(withIdentifier: "UserAuthNavController")
            self.window?.rootViewController = navController
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navController = storyboard.instantiateViewController(withIdentifier: "MainNavController")
            self.window?.rootViewController = navController
        }
        
        // Fabric / Crashlistics integration
        Fabric.with([Crashlytics.self])
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        UserAuth.setLastTime()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadSchema"), object: nil)
        
        if UserPreference.currentUser.accounts.count > 0 {
            if let navVC = self.window?.rootViewController as? BaseNavViewController, UserAuth.needLogin {
                if let _ = navVC.childViewControllers.first as? LogInViewController {
                    
                } else {
                    let storyboard = UIStoryboard(name: "Registration", bundle: nil)
                    let navController = storyboard.instantiateViewController(withIdentifier: "UserAuthNavController")
                    self.window?.rootViewController = navController
                }
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        UserAuth.setLastTime()
    }

    /*func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }*/
    

    // MARK: - CLLocation
    
    // Enable Location
    func requestLocationAuthenticating() {
        self.locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Get Location
    func getLocation() -> CLLocation? {
        let userDefault = UserDefaults.standard
        let latitude = userDefault.value(forKey: "latitude") as? CLLocationDegrees
        let longitude = userDefault.value(forKey: "longitude") as? CLLocationDegrees
        
        if latitude == nil && longitude == nil {
            if CLLocationManager.locationServicesEnabled() {
                let status = CLLocationManager.authorizationStatus()
                switch status {
                case .authorizedWhenInUse:
                    if let location = self.locationManager.location {
                        return location
                    } else {
                        self.locationManager.requestWhenInUseAuthorization()
                        self.locationManager.startUpdatingLocation()
                    }
                    break
                default:
                    break
                }
            }
        } else {
            return CLLocation(latitude: latitude!, longitude: longitude!)
        }
        
        return nil
    }
    
    func checkLocationServiceStatus(){
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted :
                //Redirect to C_F_06 Location - 1
                print("No access")
            case .denied :
                //Redirect to C_F_06 Location - 1
                print("Click on don't allow button")
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            }
        } else {
            self.displayAlertViewForDisableLocation()
            print("Location services are not enabled")
        }
    }
    
    func displayAlertViewForDisableLocation(){
        let alertController = UIAlertController(title: Messages.Location.msgDisabledService, message: Messages.Location.msgDisableDescription, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Don't Allow", comment: "don't allow title"), style: .cancel) { (action:UIAlertAction!) in
            // Redirect to Location screen
            print("Cancel Alert");
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: NSLocalizedString("Allow", comment: "allow title"), style: .default) { (action:UIAlertAction!) in
            
            let url = NSURL(string:UIApplicationOpenSettingsURLString )! as URL
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    
                    // Fallback on earlier versions
                }
            }
            else{
                print("not able to open URL")
            }
        }
        alertController.addAction(OKAction)
        
        //        self.present(alertController, animated: true, completion:nil)
        self.window?.rootViewController?.present(alertController, animated: true, completion:nil)
    }
}

