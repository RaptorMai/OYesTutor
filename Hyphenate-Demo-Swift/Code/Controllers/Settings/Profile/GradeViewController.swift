import UIKit
import Firebase
import FirebaseDatabase
import MBProgressHUD
import Hyphenate


class GradeViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: - Firebase
    var ref = Database.database().reference()
    var uid = "+1" + EMClient.shared().currentUsername!
    var selected: String {
        return UserDefaults.standard.string(forKey: "selected") ?? ""
    }
    var gradeLabel: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        gradePickerView.delegate = self
        gradePickerView.dataSource = self
        if let row = grade.index(of: selected) {
            gradePickerView.selectRow(row, inComponent: 0, animated: false)
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Properties
    var grade = ["Grade 9", "Grade 10","Grade 11","Grade 12","University 1st year","University 2nd year","University 3rd year","University 4th year","Others"]
    
    //MARK: - Outlets
    @IBOutlet weak var gradePickerView: UIPickerView!
    
    //MARK: - Interactions
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        //Upload Grade to DB
        uploadGrade(gradeLabel)
        
        // Retrive Grade from DB
        // Store data to UserDefaults
        var updatedGrade:String?
        self.ref.child("users").child(self.uid).child(DataBaseKeys.profileGradeKey).observeSingleEvent(of: .value, with: {
            (snapshot) in
            updatedGrade = snapshot.value as? String
            if updatedGrade == nil{
                UserDefaults.standard.set("Unknown", forKey: DataBaseKeys.profileGradeKey)
            } else {
                UserDefaults.standard.set(updatedGrade, forKey: DataBaseKeys.profileGradeKey)
            }
            MBProgressHUD.hide(for: self.view, animated: true)
            self.navigationController?.popViewController(animated: true)
            UserDefaults.standard.set(self.gradeLabel, forKey: "selected")
        }) {
            (error) in print (error.localizedDescription)
        }

    }
    
    //MARK: - Functions
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return grade.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return grade[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //UserDefaults.standard.set(grade[row], forKey: "selected")
        gradeLabel = grade[row]
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func uploadGrade(_ Grade: String?){
        self.ref.child("users/\(self.uid)").updateChildValues(["grade":Grade!])
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
