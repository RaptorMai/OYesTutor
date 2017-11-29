import UIKit
import Firebase
import FirebaseDatabase
import Hyphenate

class MyProfileViewControllerTableViewController: UITableViewController {
    
    // MARK: - Properties
    var ref = Database.database().reference()
    var uid = "+1" + EMClient.shared().currentUsername!
    

    // MARK: SETUP UserDefaults
    let defaultProfilePic = UIImage(named: "profile")
    
    // MARK: - View Did Load

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = false
    }
    
    // MARK: - Table navigation bar
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // color of the back button
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        // Section: PROFILE
        case 0:
            return 2
        // Section: INFORMATION
        case 1:
            return 2
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Section: PROFILE
        if indexPath.section == 0{
            switch indexPath.row {
            // Profile Picture
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "profilePictureCell", for: indexPath) as! profilePictureTableViewCell                
                if let data = UserDefaults.standard.data(forKey: DataBaseKeys.profilePhotoKey){
                    let imageUIImage = UIImage(data: data)
                    cell.profileImageView.image = imageUIImage
                } else {
                    cell.profileImageView.image = UIImage(named: "placeholder")
                }

                cell.profilePhotoLabel.text = "Profile Photo"
                return cell
            // Name
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath) as! nameTableViewCell
                cell.nameCellLabel.text = "Name"
                cell.userNameLabel.text = UserDefaults.standard.string(forKey: "userName")
                return cell
            // Should Never Reach
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            }

        // Section: INFORMARION
        } else {
            switch indexPath.row {
            // Email
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell", for: indexPath) as! emailTableViewCell
                cell.emailCellLabel.text = "Email"
                cell.userEmailLabel.text = UserDefaults.standard.string(forKey: "email")
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "changePWcell", for: indexPath) as! emailTableViewCell
                cell.emailCellLabel.text = "Change password"
                return cell

            // Should Never Reach
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileHeaderCell") as! profileHeaderTableViewCell
        switch section {
        case 0:
            cell.headerLabel.text = "Profile"
        case 1:
            cell.headerLabel.text = "Information"
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    // change Height of Profile Picture Cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0 && indexPath.row == 0){
            return 90

        }
        return 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == IndexPath(row: 1, section: 1) {
            // change pw
            resetPW()
            return
        }
        
        if indexPath == IndexPath(row: 0, section: 1) {
            // email
            let alert = UIAlertController(title: "Changing email", message: "Please contact support to change your email address", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func resetPW() {
        // copied partially from loginvc
        if let email = UserDefaults.standard.string(forKey: DataBaseKeys.profileEmailKey) {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - NOTES
    /*
     - to make headers non sticky: go to main storyboard and chage tableview style to: group
 
    */

}
