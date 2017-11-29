//
//  AppDelegate.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/12.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import Hyphenate
import UserNotifications
import Firebase
import SDWebImage
import FirebaseInstanceID
import FirebaseMessaging
import FirebaseDatabase



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, EMClientDelegate, MessagingDelegate {
    /// This method will be called whenever FCM receives a new, default FCM token for your
    /// Firebase project's Sender ID.
    /// You can send this token to your application server to send notifications to this device.


    var window: UIWindow?
    //var ref: DatabaseReference!
    
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        //Messaging.messaging().subscribe(toTopic: "topic/newQuestion")
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        UITabBar.appearance().tintColor = KermitGreenTwoColor
//        UINavigationBar.appearance().tintColor = AlmostBlackColor
        
        //ref = Database.database().reference()
        /*for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            print("\(key) = \(value) \n")
        }*/
    
        let options = EMOptions.init(appkey: "1500170706002947#instasolve")     
        
        var apnsCerName = "InstasolveTutorDevCertificates"
        #if DEBUG
            apnsCerName = "InstasolveTutorDevCertificates"
        #else
            apnsCerName = "InstasolveTutorDevCertificates"
        #endif
        
        options?.apnsCertName = apnsCerName     
        options?.enableConsoleLog = true     
        options?.isDeleteMessagesWhenExitGroup = false     
        options?.isDeleteMessagesWhenExitChatRoom = false     
        options?.usingHttpsOnly = true     
        
        EMClient.shared().initializeSDK(with: options)     
        
        //NotificationCenter.default.addObserver(self, selector: #selector(loginStateChange(nofi:)), name: NSNotification.Name(rawValue:KNOTIFICATION_LOGINCHANGE), object: nil)
        
//        let storyboard = UIStoryboard.init(name: "Launch", bundle: nil)     
//        let launchVC = storyboard.instantiateViewController(withIdentifier: "EMLaunchViewController")     
        
//        window = UIWindow.init(frame: UIScreen.main.bounds)
//        window?.backgroundColor = UIColor.white
//        window?.rootViewController = launchVC
//        window?.makeKeyAndVisible()
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        //Register notification
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        
        let token = Messaging.messaging().fcmToken

        //add to token so that it will be saved into database in future VC
        if EMClient.shared().isAutoLogin {
            proceedLogin(token)
        } else {
            proceedLogout(token)
            //EMClient.shared().options.isAutoLogin = true
        }
        
        parseApplication(application, didFinishLaunchingWithOptions: launchOptions)

        // if app is first launch
        let config = AppConfig.sharedInstance
        if config.appLaunchCount < 1 {
            config.configAppFirstLaunch()
            // show alert that only available in US and Canada
            let alert = UIAlertController(title: "Service notice", message: "Currently, we offer service to Canada and the US ONLY.\nThanks for your support!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                alert.show()
            }
        }

        // fetch and process versions/ package info, etc
        config.configAppLaunch()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // check if the user comes back from appstore when force update needed
        if AppConfig.sharedInstance.appForceUpdateRequired {
            AppConfig.sharedInstance.displayUpdateAlertForType(.ConfigTypeAppUpdateRequired)
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    //add new VC called AutoLoginVC
    func proceedLogin(_ token: String?) {
        let uid = EMClient.shared().currentUsername!
        // TODO: have to use flagged version: update on demand
        AppConfig.sharedInstance.getUserProfileAtLogin(uid)

        let autoLogin = AutoLoginVC()
        autoLogin.token = token
        window?.rootViewController = autoLogin
//        let ref = Database.database().reference()
//        let addToken = ["token": token] as [String: String?]
//        print(uid)
//        ref.child("tutors/\(uid)").updateChildValues(addToken)
//
//        let homeVC = UIStoryboard(name: "CellPrototype", bundle: nil).instantiateViewController(withIdentifier: "MainTabView")
//        let nav = UINavigationController.init(rootViewController: homeVC)
//        window?.rootViewController = homeVC
//        window?.makeKeyAndVisible()
    }
    
    
    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
    
    // logout
    func proceedLogout(_ token: String?) {
        if !EMClient.shared().isLoggedIn {
            EMClient.shared().logout(true)
            let launchVC =  LaunchViewController()
            launchVC.token = token
            let RVController = UINavigationController(rootViewController:launchVC)
            RVController.navigationBar.barStyle = .blackTranslucent
            window?.rootViewController = RVController
            
            AppConfig.sharedInstance.resetProfileDefaults()
        } else {
            proceedLogin(token)
        }
    }
    func loginStateChange(nofi: NSNotification) {
        if (nofi.object as! NSNumber).boolValue {
            let mainVC = EMMainViewController()
            let nav = UINavigationController.init(rootViewController: mainVC)
            window?.rootViewController = nav
            window?.makeKeyAndVisible()
        } else {
            let storyboard = UIStoryboard.init(name: "Register&Login", bundle: nil)     
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "EMLoginViewController")     
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        EMClient.shared().applicationDidEnterBackground(application)     
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        EMClient.shared().applicationWillEnterForeground(application)     
    }
 /*
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        EMClient.shared().registerForRemoteNotifications(withDeviceToken: deviceToken, completion: nil)
    }*/

    // Firebase notification received
    //@available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        
        // custom code to handle push while app is in the foreground
        print("Handle push from foreground\(notification.request.content.userInfo)")
        
        /*let dict = notification.request.content.userInfo["aps"] as! NSDictionary
        let d : [String : Any] = dict["alert"] as! [String : Any]
        let body : String = d["body"] as! String
        let title : String = d["title"] as! String
        print("Title:\(title) + body:\(body)")
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
        let activeController = self.window?.rootViewController as! AutoLoginVC
        
        //let activeViewCont = navigationController.visibleViewController
        
        activeController.present(alert, animated: true, completion: nil)
        //self.window?.rootViewController?.present(alert, animated: false, completion: nil)*/

    }
    
    //@available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        print("Handle push from background or closed\(response.notification.request.content.userInfo)")
    }
    


   /* fileprivate func _registerAPNS() {
        let application = UIApplication.shared     
        application.applicationIconBadgeNumber = 0     
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()     
            center.delegate = self      
            center.requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                if granted {
                    application.registerForRemoteNotifications()     
                }
            }

        }else if #available(iOS 8.0, *){
            let settings = UIUserNotificationSettings.init(types: [.badge, .sound, .alert], categories: nil)     
            application .registerUserNotificationSettings(settings)     
        }
    }*/
}


