// This file defines the config related modules, including
//   1. load config when app is launching
//   2. store the pulled data into user defaults
//   3. load local stored data from user defaults

import Foundation
import Firebase
import Alamofire


/// Enum for specifying config type
///
/// - ConfigTypeCategory: will return Data of pulled JSON file from getConfigForType()
/// - ConfigTypePackage: will return NSDictionary of pulled package info from getConfigForType()
/// - ConfigTypeAppUpdateRequired: will return Bool based on app version, from getConfigForType()
/// - ConfigTypeAppUpdateSuggested: will return Bool based on app version, from getConfigForType()
/// - ConfigTypeFirstLaunch: will return the interger count of open times from getConfigForType()
/// - ConfigTypeDiscountAvailability: will return the interger count of available discounts from getConfigForType()
/// - ConfigTypeDiscountRate: will return Double based on available discounts
enum ConfigType {
    case ConfigTypeCategory
    case ConfigTypePackage
    case ConfigTypeAppUpdateRequired
    case ConfigTypeAppUpdateSuggested
    case ConfigTypeFirstLaunch
    case ConfigTypeDiscountAvailability
    case ConfigTypeDiscountRate
}

struct DataBaseKeys {
    static let firstLaunchKey = "firstLaunchKey"
    static let packageRequiredVer = "packageUpdateReq"
    static let packageVerKey = "packageUpdateReq"
    static let packageDictionaryKey = "price"
    static let packageNeedsUpdateKey = "priceU"

    static let categoryRequiredVer = "categoryUpdateReq"
    static let categoryVerKey = "categoryUpdateReq"
    static let categoryDictionaryKey = "categoryDict"
    
    static let appRequiredVer = "tutorForcedUpdateReq"
    static let appRequiredVerKey = "tutorAppRequiredVer"
    static let appSuggestedVer = "tutorAppUpdateSuggested"
    static let appSuggestedVerKey = "tutorAppSuggestedVer"
    
    static let discountAvailabilityKey = "discountAvailable"
    static let discountRate = "discountRate"
    
    static let serverAddress = "serverAddress"
    static let appStoreLink = "appStoreLink"
    
    static let profileUserNameKey = "userName"
    static let profileEmailKey = "email"
    static let profilePhotoKey = "profilePicture"
    static let profileGradeKey = "grade"
    static let balanceKey = "balance"
    
    static let profileUserNameRemoteKey = "username"
    static let profileEmailRemoteKey = "email"
    static let profilePhotoRemoteKey = "profilePhoto"
    static let profileGradeRemoteKey = "grade"
    
    static let profileQuestionCountKey = "totalQuestionNum"
    static let profileTotalStarKey = "stars"
    static let profileEarningThisMonthKey = "earningThisMonth"

    static let profileNeedsUpdateKey = "profileNeedsUpdate"

    /// Returns db reference string based on key
    ///
    /// - Parameter key: key to query, like "forceUpdateReq"
    /// - Returns: the path for DB query, like "globalConfig/forceUpdateReq"
    static func configDBRef(_ key: String) -> String {
        return "globalConfig/\(key)"
    }
    
    static let defaultDict = [serverAddress: "us-central1-instasolve-d8c55.cloudfunctions.net" as NSObject,
                              appStoreLink: "itms://itunes.apple.com/app/apple-store/id1295553974?mt=8" as NSObject]
}

enum ConfigError: Error {
    case noUidError
    case methodNotSupportedError
}

@objc protocol ConfigDelegate {
    @objc optional func didFetchConfigTypeProfile()
}

extension String {
    func getVersionNumbers() -> (major: Int?, minor: Int?, maintain: Int?) {
        let versionArr = self.components(separatedBy: ".")
        if versionArr.count == 3 {
            return (major: Int(versionArr[0]), minor: Int(versionArr[1]), maintain: Int(versionArr[2]))
        } else {
            return (major: 0, minor: 0, maintain: 0)
        }
    }
}

/// This class provides method to load/store/get configurations, including baseURL for http request, handle required version of packages, categories and app version
class AppConfig {
    static let sharedInstance = AppConfig()
    private init() {}
    private var uid: String? = nil
    let defaults = UserDefaults.standard
    let ref: DatabaseReference! = Database.database().reference()
    
    // MARK: public vars
    var profileDelegate: ConfigDelegate?
    
    var appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"]! as! String).getVersionNumbers()
    
    var appForceUpdateRequired: Bool {
        get {
            // the
            return shouldDisplayUpdateInformation(forRequriedVersion: defaults.string(forKey: DataBaseKeys.appRequiredVerKey)!)
       }
    }

    var appUpdateSuggested: Bool {
        get {
            // the
            return shouldDisplayUpdateInformation(forRequriedVersion: defaults.string(forKey: DataBaseKeys.appSuggestedVerKey)!)
        }
    }
    
    var appLaunchCount: Int {
        get {
            return defaults.integer(forKey: DataBaseKeys.firstLaunchKey)
        }
    }
    
    var categoryJSONdata: Data? {
        get {
            return defaults.data(forKey: DataBaseKeys.categoryDictionaryKey)
        }
    }
    
    var profileNeedsUpdate: Bool {
        get {
            return defaults.integer(forKey: DataBaseKeys.profileNeedsUpdateKey) > 0
        }
    }
    
    /*var starRating: Double {
        get {
            if questionCount == 0 {
                return 5.0  // this is the default value
            }
            return defaults.double(forKey: DataBaseKeys.profileTotalStarKey) / Double(questionCount)
        }
    }
    
    var questionCount: Int {
        get {
            return defaults.integer(forKey: DataBaseKeys.profileQuestionCountKey)
        }
    }*/
    
    // MARK: private vars
    private var isAlertShown = false  // used to sync the alert, we show alert again in didBecomeActive, but needs to let it know not to show again

    // MARK: methods
    private func storeConfigForKey(_ key: String, withData dataObj: Any) {
        defaults.set(dataObj, forKey: key)
    }
    
    private func getConfigForKey(_ key: String) -> Any? {
        return defaults.object(forKey: key)
    }
    
    /// Handle different data refresh request
    /// It will compare the config(be it packege or category into)'s version number with that of the remote one. It local version is smaller, it will go fetch the new version from the cloud. It will store the pulled data in userDefaults for later reference
    ///
    /// - Parameter type: type for config request
    /// - Parameter user: the user ID, used when pulling user specific information
    func handleConfigRequestForType(_ type: ConfigType, forUser user: String? = nil) throws {
        switch type {
        case .ConfigTypeCategory:
            // check required category config version
            ref?.child(DataBaseKeys.configDBRef(DataBaseKeys.categoryRequiredVer)).observeSingleEvent(of: .value, with: { (snapshot) in
                if let requiredVersion = snapshot.value as? Int {
                    let localVersion = self.defaults.integer(forKey: DataBaseKeys.categoryVerKey)
                    print("Category version required: \(requiredVersion), local: \(localVersion)")
                    
                    if localVersion < requiredVersion {
                        self.updateCategoryJSON(toVersion: requiredVersion)
                    }
                }
            }) { (error) in
                
            }
            break
        
        case .ConfigTypeAppUpdateRequired:
            // get required version number
            ref?.child(DataBaseKeys.configDBRef(DataBaseKeys.appRequiredVer)).observeSingleEvent(of: .value, with: { (snapshot) in
                if let requiredVersion = snapshot.value as? String {
                    self.defaults.set(requiredVersion, forKey: DataBaseKeys.appRequiredVerKey)
                    if self.shouldDisplayUpdateInformation(forRequriedVersion: requiredVersion) {
                        // display
                        self.displayUpdateAlertForType(.ConfigTypeAppUpdateRequired)
                    }
                }
            }, withCancel: nil)
            
        case .ConfigTypeAppUpdateSuggested:
            // get required version number
            ref?.child(DataBaseKeys.configDBRef(DataBaseKeys.appSuggestedVer)).observeSingleEvent(of: .value, with: { (snapshot) in
                if let suggestedVer = snapshot.value as? String {
                    self.defaults.set(suggestedVer, forKey: DataBaseKeys.appSuggestedVerKey)
                    if self.shouldDisplayUpdateInformation(forRequriedVersion: suggestedVer) {
                        // display
                        self.displayUpdateAlertForType(.ConfigTypeAppUpdateSuggested)
                    }
                }
            }, withCancel: nil)
            
        default:
            break
        }
    }
    
    /// Displays the alert when app needs update. It will not display the alert twice. The alertView is displayed in appDelegate too, to prevent user resume to the app.
    func displayUpdateAlertForType(_ type: ConfigType) {
        if !isAlertShown {
            let alertView = UIAlertController(title: "New version available", message: "", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Goto App Store", style: .default, handler: { (_) in
                self.isAlertShown = false
                // TODO
                let appStoreURLString = "AppStore"
                UIApplication.shared.open((URL(string: appStoreURLString)!))
            }))
            switch type {
            case .ConfigTypeAppUpdateRequired:
                alertView.message = "Please update the app to newer version"
            case .ConfigTypeAppUpdateSuggested:
                alertView.message = "Please consider updating the app to newer version"
                alertView.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: {(_) in
                    self.isAlertShown = false
                }))
            default:
                return
            }
            
            // to prevent alert from displaying twice
            self.isAlertShown = true
            DispatchQueue.main.async {
                alertView.show()
            }
        }
    }

    
    /// Call this function to see if the current app version needs update, compare to the version string supplied
    ///
    /// - Parameter ver: the (maybe) newer version that you want to compare against the current app version
    /// - Returns: true if the current version is lower, false otherwise
    func shouldDisplayUpdateInformation(forRequriedVersion ver: String) -> Bool {
        // let (major, minor, maintain) = ver.getVersionNumbers()
        let requiredVer = ver.getVersionNumbers()
        
        if let major = requiredVer.major, let minor = requiredVer.minor, let maintain = requiredVer.maintain {
            if let appMajor = appVersion.major, let appMinor = appVersion.minor, let appMaintain = appVersion.maintain {
                if major > appMajor {
                    return true
                } else if minor > appMinor {
                    return true
                } else if maintain > appMaintain {
                    return true
                }
            }
        }
        
        return  false
    }
    
    /// Pulls new category Json from cloud
    ///
    /// - Parameter ver: the newest version number of config
    func updateCategoryJSON(toVersion ver: Int) {
        Alamofire.request(urlForNetworkAPI(.category)!).responseJSON { (response) in
            switch response.result {
            case .failure(let fail):
                print(fail.localizedDescription)
            default:
                break
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                // store JSON data
                self.storeConfigForKey(DataBaseKeys.categoryDictionaryKey, withData: data)
                print("New config: \(utf8Text)")

                // update the required version number
                self.defaults.set(ver, forKey: DataBaseKeys.categoryVerKey)
            }
        }
    }
    
    
    /// Decrements the count for specific types of config
    ///
    /// Now supports ConfigTypeDiscountAvailability
    /// - Parameter type: ConfigType
    /// - Throws: ConfigError
    func decrementCountForConfigType(_ type: ConfigType, withStep step: Int = 1) throws {
        switch type {
        case .ConfigTypeDiscountAvailability:
            let key = DataBaseKeys.discountAvailabilityKey
            let currentDiscountAvailablity = defaults.integer(forKey: key) - step
            defaults.set(currentDiscountAvailablity, forKey: key)
            try! updateRemoteValueForType(.ConfigTypeDiscountAvailability, forUser: uid!)
        default:
            throw ConfigError.methodNotSupportedError
        }
    }
    
    /// Register user defaults when app first launches
    func configAppFirstLaunch() {
        let initialUserDefaults: [String:Int] = [DataBaseKeys.categoryVerKey: -1,
                                                 DataBaseKeys.packageVerKey: -1,
                                                 DataBaseKeys.firstLaunchKey: 0,  // TODO: check after user switch
                                                 DataBaseKeys.profileNeedsUpdateKey: 1,
                                                ]
        
        defaults.register(defaults: initialUserDefaults)
        
        let initialProfileDefaults: [String:String] = [DataBaseKeys.profileEmailKey: "example@gmail.com",
                                                       DataBaseKeys.profileUserNameKey: "Please complete profile",
                                                       DataBaseKeys.profileGradeKey: "Others",
                                                       DataBaseKeys.appRequiredVerKey: "1.0.0",
                                                       DataBaseKeys.appSuggestedVerKey: "1.0.0",
                                                       ]
        
        defaults.register(defaults: initialProfileDefaults)
        
        // setting profile photo to placeholder
        defaults.register(defaults: [DataBaseKeys.profilePhotoKey: UIImageJPEGRepresentation(UIImage(named:"placeholder")!, 1)!])
        defaults.set(-1, forKey: DataBaseKeys.categoryVerKey)
        defaults.set(-1, forKey: DataBaseKeys.packageVerKey)
        defaults.set(0, forKey: DataBaseKeys.firstLaunchKey)
        defaults.set(1, forKey: DataBaseKeys.profileNeedsUpdateKey)
        defaults.set(0, forKey: DataBaseKeys.profileQuestionCountKey)
        defaults.set(0.0, forKey: DataBaseKeys.profileTotalStarKey)
        defaults.set(0.0, forKey: DataBaseKeys.profileEarningThisMonthKey)
        defaults.set("example@gmail.com", forKey: DataBaseKeys.profileEmailKey)
        defaults.set("Please complete profile", forKey: DataBaseKeys.profileUserNameKey)
        defaults.set("1.0.0", forKey: DataBaseKeys.appRequiredVerKey)
        defaults.set("1.0.0", forKey: DataBaseKeys.appSuggestedVerKey)
        defaults.set(UIImageJPEGRepresentation(UIImage(named:"placeholder")!, 1)!, forKey: DataBaseKeys.profilePhotoKey)
        defaults.synchronize()
    }
    
    /// Call this function for first time users
    func resetProfileDefaults() {
        defaults.set("example@gmail.com", forKey: DataBaseKeys.profileEmailKey)
        defaults.set("Please complete profile", forKey: DataBaseKeys.profileUserNameKey)
        defaults.set("Others", forKey: DataBaseKeys.profileGradeKey)
        defaults.set(1, forKey: DataBaseKeys.profileNeedsUpdateKey)
        defaults.set(UIImageJPEGRepresentation(UIImage(named:"placeholder")!, 1)!, forKey: DataBaseKeys.profilePhotoKey)
    }
    
    /// Fetch user default from cloud when user first log in
    ///
    /// - Parameter uid: user ID
    func getUserProfileAtLogin(_ uid: String) {
        // user name
        ref?.child("tutors/\(uid)/\(DataBaseKeys.profileUserNameRemoteKey)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? String {
                self.defaults.set(value, forKey: DataBaseKeys.profileUserNameKey)
                self.profileDelegate?.didFetchConfigTypeProfile!()
            }
        })
        
        // profile photo
        ref?.child("tutors/\(uid)/\(DataBaseKeys.profilePhotoRemoteKey)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let picURLString = snapshot.value as? String {
                // value is the URL for image, has to download and set to data
                if let picURL = URL(string: picURLString) {
                    Alamofire.request(picURL, method: HTTPMethod.get).responseData(completionHandler: { (data) in
                        if let imageData = data.data {
                            self.defaults.set(imageData, forKey: DataBaseKeys.profilePhotoKey)
                            self.profileDelegate?.didFetchConfigTypeProfile!()
                        }
                    })
                }
            }
        })
        
        // email
        ref?.child("tutors/\(uid)/\(DataBaseKeys.profileEmailRemoteKey)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? String {
                self.defaults.set(value, forKey: DataBaseKeys.profileEmailKey)
                self.profileDelegate?.didFetchConfigTypeProfile!()
            }
        })
        
        //balance
        ref?.child("tutors/\(uid)/\(DataBaseKeys.balanceKey)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? Int {
                self.defaults.set(value, forKey: DataBaseKeys.balanceKey)
            }
        })
        /*
        // question count
        ref?.child("tutors/\(uid)/\(DataBaseKeys.profileQuestionCountKey)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? Int {
                self.defaults.set(value, forKey: DataBaseKeys.profileQuestionCountKey)
                self.profileDelegate?.didFetchConfigTypeProfile!()
            }
        })
        
        // star count
        ref?.child("tutors/\(uid)/\(DataBaseKeys.profileTotalStarKey)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? Int {
                self.defaults.set(value, forKey: DataBaseKeys.profileTotalStarKey)
                self.profileDelegate?.didFetchConfigTypeProfile!()
            }
        })
        
        // earning this month
        ref?.child("tutors/\(uid)/\(DataBaseKeys.profileEarningThisMonthKey)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? Double {
                self.defaults.set(value, forKey: DataBaseKeys.profileEarningThisMonthKey)
                self.profileDelegate?.didFetchConfigTypeProfile!()
            }
        })*/

        defaults.set(0, forKey: DataBaseKeys.profileNeedsUpdateKey)
        defaults.synchronize()
    }
    
    /// Do app refresh at launch, it does: 1. handle remote config, 2. check category/package for necessary update, 3. increment open count
    func configAppLaunch() {
        // remote config
//        let remoteConfig = RemoteConfig.remoteConfig()
//        remoteConfig.setDefaults(DataBaseKeys.defaultDict)
//
//        // activate the fetched data from last time app is opened
//        remoteConfig.fetch { (status, error) in
//            guard error == nil else {return}
//            remoteConfig.activateFetched()
//        }
        
        // get category update event, the snapshot should be int
        // TODO: handle throw
        try! handleConfigRequestForType(.ConfigTypeAppUpdateRequired)
        try! handleConfigRequestForType(.ConfigTypeAppUpdateSuggested)
        try! handleConfigRequestForType(.ConfigTypePackage)
        try! handleConfigRequestForType(.ConfigTypeCategory)
        try! handleConfigRequestForType(.ConfigTypeDiscountRate)
        
        // increment open counter
        defaults.set(defaults.integer(forKey: DataBaseKeys.firstLaunchKey) + 1, forKey: DataBaseKeys.firstLaunchKey)
        print(appVersion)
        defaults.synchronize()
    }
    
    
    /// Fetch data for user specified with UID
    ///
    /// This function should be called when ever user log in info changes, like when login/app launch
    /// - Parameter uid: String UID of hyphenate user name
    func performUserSpecificConfigFor(_ uid: String) {
        self.uid = uid
        try! handleConfigRequestForType(.ConfigTypeDiscountAvailability, forUser: uid)
    }
    
    // Update remote's value
    /// Update configType's current value to FireBase
    /// Supported type: ConfigTypeDiscountAvailability
    /// - Parameter type: type of config to update
    func updateRemoteValueForType(_ type: ConfigType, forUser user: String? = nil) throws {
        switch type {
        case .ConfigTypeDiscountAvailability:
            if let uid = user {
                let key = DataBaseKeys.discountAvailabilityKey
                let currentDiscountAvailablity = defaults.integer(forKey: key)
                ref?.child("tutors/\(uid)/").updateChildValues([key: currentDiscountAvailablity as Any])
            } else {
                throw ConfigError.noUidError
            }
            
        default:
            throw ConfigError.methodNotSupportedError
        }
    }
    
    func processUserLogout() {
        // when user logout, it needs to clear user specific data, including
        // 1. discount available
        defaults.set(0, forKey: DataBaseKeys.discountAvailabilityKey)
        
        // set the user profile defaults to initial values
        resetProfileDefaults()
    }
    
    func saveConfig() {
        defaults.synchronize()
    }
}

