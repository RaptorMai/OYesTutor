//
//  AutoLoginVC.swift
//  Hyphenate-Demo-Swift
//
//  Created by ZHEDA MAI on 2017-09-18.
//  Copyright © 2017 杜洁鹏. All rights reserved.
//

import UIKit
import Hyphenate
import Firebase


class AutoLoginVC: UIViewController {
    var token: String?
    var ref: DatabaseReference?
    let uid = EMClient.shared().currentUsername!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let homeVC = UIStoryboard(name: "CellPrototype", bundle: nil).instantiateViewController(withIdentifier: "MainTabView")
//        self.present(homeVC, animated: true, completion: nil)
        // Update notification token
        let addToken = ["token": self.token] as [String: String?]
        print(uid)
        self.ref?.child("tutors/\(uid)").updateChildValues(addToken)
        UIApplication.shared.delegate?.window??.rootViewController = homeVC
    }
    


}
