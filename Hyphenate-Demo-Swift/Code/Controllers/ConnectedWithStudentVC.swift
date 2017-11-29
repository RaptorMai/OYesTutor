//
//  ConnectedWithStudentVC.swift
//  Hyphenate-Demo-Swift
//
//  Created by devuser on 2017-08-28.
//  Copyright © 2017 杜洁鹏. All rights reserved.
//

import UIKit
import Hyphenate
import Firebase

class ConnectedWithStudentVC: UIViewController {

    var requestorSid: NSString?
    var category: String?
    var qid: String?
    var image: UIImage?
    var questDescription: String?
    var ref: DatabaseReference?

    @IBOutlet weak var questionImage: UIImageView!
    
    @IBOutlet weak var questionDesrciption: UITextView!
    
    
    @IBOutlet weak var connect: UIButton!
    
    @IBAction func readyToConnect(_ sender: UIButton) {
        //set status to 2, means tutor is reayd to chat
        self.ref?.child("Request/active/\(self.category!)/\(self.qid!)").updateChildValues(["status": 2])
         let sessionController = EMChatViewController.init(requestorSid! as String, EMConversationTypeChat)
         sessionController.category = category!
         sessionController.key = qid!
        
//         let navC = UINavigationController(rootViewController: sessionController)
//         self.navigationController?.present(navC, animated: true, completion: nil)
        navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(sessionController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = true
        questionImage.image = image
        questionDesrciption.text = questDescription
        questionDesrciption.isEditable = false
        questionImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(expandimage))
        self.questionImage.addGestureRecognizer(tapGesture)
        connect.layer.cornerRadius = 8
       
    }

    
    func expandimage(){
        if let image = questionImage.image{
            let agrume = Agrume(image: image, backgroundColor: .black)
            agrume.hideStatusBar = true
            agrume.showFrom(self)
        }
    }


}
