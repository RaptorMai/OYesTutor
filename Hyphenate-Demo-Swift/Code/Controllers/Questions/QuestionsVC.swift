//
//  HomeViewController.swift
//  TutorApp
//
//  Created by devuser on 2017-08-06.
//  Copyright © 2017 sul. All rights reserved.
//

import UIKit
import Foundation
import MBProgressHUD
import Cosmos
import Firebase
import Hyphenate


protocol refreshSpinnerProtocol {
    func removeSpinner()
}


class QuestionsVC: UIViewController, refreshSpinnerProtocol, ConfigDelegate {
    let ref: DatabaseReference! = Database.database().reference()
    let pay = [3:10.0,3.5:11.0,4:12.0,4.5:14.0,5:16.0]
    // function:
    func refreshTable(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
        MBProgressHUD.showAdded(to: tableofquestions, animated: true)
    }
    
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
        MBProgressHUD.showAdded(to: tableofquestions, animated: true)
    }
    
    @IBOutlet weak var starView: CosmosView!  // settings in the IB
    
    @IBOutlet weak var tableofquestions: UIView!
    
    @IBOutlet weak var tutorName: UILabel!
    
    @IBOutlet weak var tutorProfilePicture: UIImageView!
    
    @IBOutlet weak var earningLabel: UILabel!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "magic"{
            let childVC = segue.destination as? MainTableViewController
            childVC?.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // profile loading delegate
        AppConfig.sharedInstance.profileDelegate = self
        extendedLayoutIncludesOpaqueBars = false
    }
    
    override func viewDidLayoutSubviews() {
        refreshInformationBanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshInformationBanner()
        updateStarEarning()
    }
    
    
    /// Refreshes the banner that displays the tutor info
    func refreshInformationBanner() {
        if let data = UserDefaults.standard.data(forKey: DataBaseKeys.profilePhotoKey) {
            tutorProfilePicture.image = UIImage(data: data)!
        } else {
            // TODO: MAKE SURE PLACEHOLDER IS THERE
            tutorProfilePicture.image = UIImage(named:"placeholder")!
        }
        tutorProfilePicture.layer.masksToBounds = true
        tutorProfilePicture.layer.cornerRadius = tutorProfilePicture.frame.size.width / 2
        
        if let name = UserDefaults.standard.string(forKey: DataBaseKeys.profileUserNameKey){
            tutorName.text = name
        } else {
            tutorName.text = "Unknown"
        }
        
        
    }
    func updateStarEarning(){
        let date = Date()
        let calendar = Calendar.current
        let currentMonth = "\(calendar.component(.year, from: date))" + "\(calendar.component(.month, from: date))"
        var rating = 5.0
        var starts = 0
        var minutes = 0
        var qNum = 0
        var earning = 0.0
        let myGroup = DispatchGroup()
        let uid = EMClient.shared().currentUsername!
        myGroup.enter()
        ref?.child("tutors/\(uid)/monthlyBalanceHistory/\(currentMonth)/monthlyTotal").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? Int {
                minutes = value
                myGroup.leave()
            }
        })
        myGroup.enter()
        ref?.child("tutors/\(uid)/monthlyBalanceHistory/\(currentMonth)/stars").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? Int {
                starts = value
                myGroup.leave()
                
            }
        })
        myGroup.enter()
        ref?.child("tutors/\(uid)/monthlyBalanceHistory/\(currentMonth)/qnum").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? Int {
                qNum = value
                myGroup.leave()
            }
        })
        myGroup.notify(queue: .main) {
            rating = Double(starts)/Double(qNum)
            self.starView.rating = rating
            self.starView.text = String(format: "%.1f", rating)  // round up
            switch rating {
            case 0...3:
                earning = Double(Double(minutes)/60 * self.pay[3]!)
            case 3...3.5:
                earning = Double(Double(minutes)/60 * self.pay[3.5]!)
            case 3.5...4:
                earning = Double(Double(minutes)/60 * self.pay[4]!)
            case 4...4.5:
                earning = Double(Double(minutes)/60 * self.pay[4.5]!)
                if qNum >= 20{
                    earning += 10
                }
            case 4.5...5:
                earning = Double(Double(minutes)/60 * self.pay[5]!)
                if qNum >= 20{
                    earning += 15
                }
            default:
                earning = 0
            }
            self.earningLabel.text = String(format: "$ %.2f", earning)
        }
    }
    func removeSpinner(){
        
        MBProgressHUD.hideAllHUDs(for: tableofquestions, animated: true)
        
    }
    
    // Mark: - Config delegate
    func didFetchConfigTypeProfile() {
        refreshInformationBanner()
    }
    
}
