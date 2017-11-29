import UIKit
import Firebase
import Hyphenate
import MessageUI

class SettingsVC: UITableViewController, MFMailComposeViewControllerDelegate {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "Settings"
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        self.tableView.backgroundColor = UIColor.init(hex: "F0EFF5")
        self.tableView.separatorInset = .zero
        self.tableView.layoutMargins = .zero
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(UINib(nibName: "SwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "switchCell")
        self.tableView.register(UINib(nibName: "LabelTableViewCell", bundle: nil), forCellReuseIdentifier: "labelCell")
        // Do any additional setup after loading the view.
        
        tableView.isScrollEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let data = [[[#imageLiteral(resourceName: "Profile"),"Profile"]], [[#imageLiteral(resourceName: "Bank"),"Bank account"], [#imageLiteral(resourceName: "Cash"),"Cash out"]], [[#imageLiteral(resourceName: "Help"),"Help"], [#imageLiteral(resourceName: "Feedback"),"Feedback"], [#imageLiteral(resourceName: "About"),"About"]],[["Log out"]]]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section != 3{
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = self.data[indexPath.section][indexPath.row][1] as? String
            cell.imageView?.image = self.data[indexPath.section][indexPath.row][0] as? UIImage
            
            cell.accessoryType = .disclosureIndicator
            return cell}
        else{
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = self.data[indexPath.section][indexPath.row][0] as? String
            cell.textLabel?.textAlignment = .center
            return cell
            
        }
        
    }
    
    let profileIndexPath = IndexPath(row: 0, section: 0)
    let bankAccountIndexPath = IndexPath(row: 0, section: 1)
    let cashOutIndexPath = IndexPath(row: 1, section: 1)
    let helpIndexPath = IndexPath(row: 0, section: 2)
    let feedbackIndexPath = IndexPath(row: 1, section: 2)
    let aboutIndexPath = IndexPath(row: 2, section: 2)
    let logoutIndexPath = IndexPath(row: 0, section: 3)

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("prssed section \(indexPath.section) row \(indexPath.row)")
        switch indexPath {
        case profileIndexPath:
            let StoryBoard = UIStoryboard(name:"ProfileMain",bundle:nil)
            let myProfileVC = StoryBoard.instantiateViewController(withIdentifier: "myProfileVC")
            
            tabBarController?.tabBar.isHidden = true
            navigationController?.pushViewController(myProfileVC, animated: true)

        case bankAccountIndexPath:
            fallthrough
        case cashOutIndexPath:
            // not supported
            let alertView = UIAlertController(title: "Wait...",
                                              message: "The bank function is not supported in this version, please contact us for any issue",
                                              preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertView, animated: true, completion: nil)
        
        case helpIndexPath:
            openURL("https://www.instasolve.ca/become-a-turor")
        
        case feedbackIndexPath:
            if !MFMailComposeViewController.canSendMail(){
                print("Mail services are not available")
                // display alert
                let alertView = UIAlertController(title: "Mail cannot be sent", message: "Please setup your mailbox on iOS Settings first", preferredStyle: .alert )
                alertView.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                self.present(alertView, animated: true)
            } else {
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                // Configure the fields of the interface
                composeVC.setToRecipients(["instasolve1@gmail.com"])
                composeVC.setSubject("Feedback - InstaSolve")
                composeVC.setMessageBody("Please leave us your precious feedback!", isHTML: false)
                self.present(composeVC, animated: true, completion:nil)
            }
            
        case aboutIndexPath:
            openURL("https://www.instasolve.ca")
            
        case logoutIndexPath:
            logoutAction()

        default:break

        }
    }

    func logoutAction() {
        
        try! Auth.auth().signOut()
        
        //TODO add hyphenate logout
        EMClient.shared().logout(true) { (error) in
            if let _ = error {
                let alert = UIAlertController(title:"Sign Out error", message: "Please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            } else {
                let LoginScreenNC = UINavigationController(rootViewController: LaunchViewController())
                LoginScreenNC.navigationBar.barStyle = .blackTranslucent
                self.present(LoginScreenNC, animated: true, completion: nil)
                
            }
        }
    }

    func openURL(_ url: String) {
        let openMainPageVc = OpenUrlViewController()
        openMainPageVc.url = url
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(openMainPageVc, animated: true)
    }
    
    // MARK: - Mail delegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case MFMailComposeResult.cancelled:
            print("Mail cancelled")
        case MFMailComposeResult.saved:
            print("Mail saved")
        case MFMailComposeResult.sent:
            print("Mail sent")
        case MFMailComposeResult.failed:
            print("Mail sent failure")
        }
        // Dismiss mail view controller and back to setting page
        self.dismiss(animated:true, completion: nil)
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
