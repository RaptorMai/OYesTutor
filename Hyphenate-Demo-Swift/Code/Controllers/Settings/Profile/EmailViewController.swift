//
//  EmailViewController.swift
//  ProfileSetting
//
//  Created by Yi Jerry on 2017-09-23.
//  Copyright © 2017 Yi Jerry. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import MBProgressHUD
import Hyphenate


class EmailViewController: UIViewController, UITextFieldDelegate {
    // Database
    var ref: DatabaseReference! = Database.database().reference()
    var uid = EMClient.shared().currentUsername!

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // get email from DB
        self.EmailText.text = UserDefaults.standard.string(forKey: DataBaseKeys.profileEmailKey)
        EmailText.becomeFirstResponder()
        EmailText.clearButtonMode = .always
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var EmailText: UITextField!
    
    @IBAction func Save(_ sender: UIBarButtonItem) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        //Upload Email to DB
        var email = EmailText.text
        email = email?.trimmingCharacters(in: .whitespacesAndNewlines)
        if verifyEmail(email: email!){
        uploadEmail(email!)
        
        // Retrive Email from firebase
        // Store data to UserDefaults
        self.ref.child("tutors").child(uid).child(DataBaseKeys.profileEmailKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                let val = snapshot.value as? String
                if (val! != ""){
                    UserDefaults.standard.set(val, forKey: DataBaseKeys.profileEmailKey)
                }
                else{
                    print("Username is an empty string!")
                    UserDefaults.standard.set("Unknown", forKey: DataBaseKeys.profileEmailKey)
                }
            }
            MBProgressHUD.hide(for: self.view, animated: true)
            self.navigationController?.popViewController(animated: true)
        }) { (error) in print(error.localizedDescription)}
        }else{
            let alert = UIAlertController(title: "Alert", message: "Incorrect Email Format", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func uploadEmail(_ email: String){
        self.ref?.child("tutors/\(self.uid)").updateChildValues(["email":email])
    }
    
    // Verify Email format
    func verifyEmail(email: String) -> Bool{
        if email == "" {
            return true
        }
        
        emailField.text = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailField.text!
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,15}"
        let emailverify = NSPredicate(format:"SELF MATCHES %@",emailRegEx)
        let res = emailverify.evaluate(with: email)
        return res
    }
    
    // Dismiss Keyboard
    func handleTap(_ tapGesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: textfielddelegate
    // handle return press on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        Save(saveButton)
        return true
    }
}






