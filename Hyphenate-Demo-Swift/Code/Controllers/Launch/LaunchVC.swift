//
//  ViewController.swift
//  TutorApp
//
//  Created by devuser on 2017-08-02.
//  Copyright © 2017 sul. All rights reserved.
//

import UIKit
import Firebase

//Name change for this VC
class LaunchViewController: UIViewController {

    let screenHeight = UIScreen.main.bounds.height
    let screenWidth  = UIScreen.main.bounds.width
    var token: String?

    
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
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.plain, target: nil, action: nil)
        let loginVC = LoginVC()
        loginVC.token = self.token
        navigationController?.pushViewController(loginVC, animated: true)
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
        
        view.backgroundColor = UIColor.init(hex: "2F2F2F")
        view.addSubview(MainLabel)
        setupMainLabel()
        view.addSubview(TutorLabel)
        setupTutorLabel()
        view.addSubview(RegisterButton)
        setupRegisterButton()
        view.addSubview(LoginButton)
        setupLoginButton()
        
        
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

