//
//  ViewController.swift
//  TutorApp
//
//  Created by devuser on 2017-08-02.
//  Copyright © 2017 sul. All rights reserved.
//

import UIKit
import Firebase
import Hyphenate
import MBProgressHUD
import Foundation

//Name change for this VC
class LaunchViewController: UIViewController {

    let screenHeight = UIScreen.main.bounds.height
    let screenWidth  = UIScreen.main.bounds.width
    var token: String?
    let controller = LFLoginController()
    var ref: DatabaseReference?
    
    let MainLabel: UILabel = {
        let label = UILabel()
        label.text = "InstaSolve"
        label.textColor = UIColor.white
        label.font = UIFont(name: "Georgia", size: 50)
        return label
        
    }()
    
    func setupMainLabel(){
        MainLabel.translatesAutoresizingMaskIntoConstraints = false
        MainLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        MainLabel.topAnchor.constraint(equalTo: view.topAnchor, constant:UIScreen.main.bounds.height*labelToTop).isActive = true
    }
    
    let TutorLabel: UILabel = {
        let label = UILabel()
        label.text = "Tutor"
        label.textColor = UIColor.white
        label.font = UIFont(name: "Helvetica", size: 30)
        return label
        
    }()
    
    func setupTutorLabel(){
        TutorLabel.translatesAutoresizingMaskIntoConstraints = false
        TutorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        TutorLabel.topAnchor.constraint(equalTo: MainLabel.bottomAnchor, constant:10).isActive = true
    }
    
    let RegisterButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 20)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(hex: "B3B7BB")
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(Register), for: .touchUpInside)
        return button
    }()
    
    func Register(){
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.plain, target: nil, action: nil)
        let openMainPageVc = OpenUrlViewController()
        openMainPageVc.url = "https://www.instasolve.ca/become-a-turor"
        navigationController?.pushViewController(openMainPageVc, animated: true)
    }
    
    func setupRegisterButton(){
        RegisterButton.translatesAutoresizingMaskIntoConstraints = false
        RegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -UIScreen.main.bounds.width * buttonIntervalFactor).isActive = true
        RegisterButton.topAnchor.constraint(equalTo: TutorLabel.bottomAnchor, constant:UIScreen.main.bounds.height*buttonToLabel).isActive = true
        RegisterButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * buttonWidthFactor).isActive = true
        RegisterButton.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height*buttonHightFacotor).isActive = true
    }
    
    let LoginButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 20)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(hex: "DEC164")
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(Login), for: .touchUpInside)
        return button
    }()
    
    func Login(){
        //navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.plain, target: nil, action: nil)
        //let loginVC = LoginVC()
        //loginVC.token = self.token
        //navigationController?.pushViewController(loginVC, animated: true)
        navigationController?.pushViewController(controller, animated: true)
    }
    let buttonWidthFactor:CGFloat = 0.4
    let buttonHightFacotor: CGFloat = 0.07
    let buttonIntervalFactor:CGFloat = 0.25
    let buttonToLabel: CGFloat = 0.58
    let labelToTop: CGFloat = 0.14
    func setupLoginButton(){
        LoginButton.translatesAutoresizingMaskIntoConstraints = false
        //LoginButton.centerXAnchor.constrain
        LoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: UIScreen.main.bounds.width * buttonIntervalFactor).isActive = true
        LoginButton.topAnchor.constraint(equalTo: TutorLabel.bottomAnchor, constant:UIScreen.main.bounds.height*buttonToLabel).isActive = true
        LoginButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * buttonWidthFactor).isActive = true
        LoginButton.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height*buttonHightFacotor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        view.backgroundColor = UIColor.init(hex: "2F2F2F")
        view.addSubview(MainLabel)
        setupMainLabel()
        view.addSubview(TutorLabel)
        setupTutorLabel()
        view.addSubview(RegisterButton)
        setupRegisterButton()
        view.addSubview(LoginButton)
        setupLoginButton()
        controller.delegate = self
        
        // Customizations
        //controller.logo = UIImage(named: "AwesomeLabsLogoWhite")
        //controller.isSignupSupported = false
        //controller.backgroundColor = UIColor(red: 224 / 255, green: 68 / 255, blue: 98 / 255, alpha: 1)
        //controller.videoURL = Bundle.main.url(forResource: "PolarBear", withExtension: "mov")!
        controller.loginButtonColor = UIColor.purple
        //        controller.setupOnePassword("YourAppName", appUrl: "YourAppURL")
        
        
    }
    func UsernameValid(_ Username: String) -> Bool{
        //self.show("Logging in")
        let email = Username
        let emailNoSpace = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if emailNoSpace == ""{
            let alert = UIAlertController(title: "Error", message: "Email can't be empty", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(okay)
            self.hideHub()
            self.present(alert, animated: true, completion: nil)
            return false
        }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,15}"
        let emailverify = NSPredicate(format:"SELF MATCHES %@",emailRegEx)
        let res = emailverify.evaluate(with: emailNoSpace)
        if !res{
            let alert = UIAlertController(title: "Error", message: "Email is badly formatted", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(okay)
            self.hideHub()
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return res
    }
    func PasswordValid(_ Password: String) -> Bool{
        let pw = Password
        //self.show("Logging in")
        let pwNoSpace = pw.trimmingCharacters(in: .whitespacesAndNewlines)
        if pwNoSpace == ""{
            let alert = UIAlertController(title: "Error", message: "Password can't be empty", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(okay)
            self.hideHub()
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*
        if Auth.auth().currentUser != nil {
            let homeVC = UIStoryboard(name: "CellPrototype", bundle: nil).instantiateViewController(withIdentifier: "MainTabView")
            self.present(homeVC, animated: true, completion: nil)
            
        }*/
    }



}

extension LaunchViewController: LFLoginControllerDelegate {
    
    func loginDidFinish(email: String, password: String, type: LFLoginController.SendType) {
        
        // Implement your server call here
        
        print(email)
        print(password)
        print(type)
        
        if UsernameValid(email) && PasswordValid(password) {
            let emailNoSpace = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let pw = password
            let pwNoSpace = pw.trimmingCharacters(in: .whitespacesAndNewlines)
            self.show("Logging in")
            Auth.auth().signIn(withEmail: emailNoSpace, password: pwNoSpace) { (user, error) in
                if error != nil {
                    self.hideHub()
                    self.controller.wrongInfoShake()
                    let alert = UIAlertController(title: "Error", message: "\((error?.localizedDescription)!)", preferredStyle: .alert)
                    let okay = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(okay)
                    self.present(alert, animated: true, completion: nil)
                    
                }
                else{
                    var usernameNoSign = email.replacingOccurrences(of: "@", with: "")
                    usernameNoSign = usernameNoSign.replacingOccurrences(of: ".", with: "")
                    usernameNoSign = usernameNoSign.lowercased()
                    //let uid = EMClient.shared().currentUsername!
                    AppConfig.sharedInstance.getUserProfileAtLogin(usernameNoSign)
                    weak var weakSelf = self
                    EMClient.shared().login(withUsername: usernameNoSign, password: usernameNoSign) { (username, error) in
                        if error == nil {
                            self.hideHub()
                            EMClient.shared().options.isAutoLogin = true
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue:KNOTIFICATION_LOGINCHANGE), object: NSNumber(value: true))
                            //Save token to firebase
                            if let tokenNotNil = self.token{
                                let addToken = ["token": tokenNotNil] as [String: String?]
                                self.ref?.child("tutors/\(usernameNoSign)").updateChildValues(addToken)
                            }
                            let homeVC = UIStoryboard(name: "CellPrototype", bundle: nil).instantiateViewController(withIdentifier: "MainTabView")
                            self.present(homeVC, animated: true, completion: nil)
                        } else {
                            self.hideHub()
                            var alertStr = ""
                            switch error!.code {
                            case EMErrorUserNotFound:
                                alertStr = error!.errorDescription
                                break
                            case EMErrorNetworkUnavailable:
                                alertStr = error!.errorDescription
                                break
                            case EMErrorServerNotReachable:
                                alertStr = error!.errorDescription
                                break
                            case EMErrorUserAuthenticationFailed:
                                alertStr = error!.errorDescription
                                break
                            case EMErrorServerTimeout:
                                alertStr = error!.errorDescription
                                break
                            default:
                                alertStr = error!.errorDescription
                                break
                            }
                            
                            let alertView = UIAlertView.init(title: nil, message: alertStr, delegate: nil, cancelButtonTitle: "okay")
                            alertView.show()
                        }
                    }
                }
            }
        }
    }

    func forgotPasswordTapped(email: String) {
        print("forgot password: \(email)")
        if UsernameValid(email){
            let emailNoSpace = email.trimmingCharacters(in: .whitespacesAndNewlines)
            self.show("")
            Auth.auth().sendPasswordReset(withEmail: emailNoSpace) { error in
                self.hideHub()
                if error != nil{
                    let alert = UIAlertController(title: "Error", message: "\((error?.localizedDescription)!)", preferredStyle: .alert)
                    let okay = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(okay)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    let alert = UIAlertController(title: "Email Sent", message: "Please check Email and reset password", preferredStyle: .alert)
                    let okay = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(okay)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

