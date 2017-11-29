import UIKit
import Firebase
import FirebaseDatabase
import MBProgressHUD
import Hyphenate

class ProfileSettingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Firebase
    //var ref: DatabaseReference!
    var ref = Database.database().reference()
    var uid = EMClient.shared().currentUsername!
    
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        
        if let data = UserDefaults.standard.data(forKey: DataBaseKeys.profilePhotoKey){
            let imageUIImage = UIImage(data: data)
            imageView.image = imageUIImage
        }else{
            imageView.image = UIImage(named:"placeholder")
        }
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        // using constraints, the frame can change
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
    }
    
    // MARK: - Title
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK - Interaction
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        if Reachability.isConnectedToNetwork(){
            MBProgressHUD.showAdded(to: self.view, animated: true)
            let imageData: Data = UIImagePNGRepresentation(imageView.image!)!
            // Upload Profile Picture to DB
            uploadPicture(imageData, completion:{ (url) -> Void in
                
                if url == nil{
                    print("Url is nil")
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.createNetworkAlert()
                } else {
                print("Uploading profile pic")
                self.ref.child("tutors/\(self.uid)").updateChildValues([DataBaseKeys.profilePhotoRemoteKey: url!])
                
                print("Finished upload")
                print("Going to download from DB")
                // Retrive Profile Picture from DB
                // Store data to UserDefaults
            self.ref.child("tutors").child(self.uid).child(DataBaseKeys.profilePhotoRemoteKey).observeSingleEvent(of: .value, with: {(snapshot) in
                    
                    print("downloaded from DB")
                    var imageBuffer: UIImage
                    
                    if snapshot.exists(){
                        let val = snapshot.value as? String
                        print(val)
                        if (val == nil){
                            imageBuffer = UIImage(named: "placeholder")!
                            let imgData = UIImageJPEGRepresentation(imageBuffer, 1)
                            UserDefaults.standard.set(imgData, forKey: DataBaseKeys.profilePhotoKey)
                        }
                        else{
                            print("Recieve Non-null image")
                            print("Setting UsersDefault")
                            let imgData = UIImageJPEGRepresentation(self.imageView.image!, 1)
                            UserDefaults.standard.set(imgData, forKey: DataBaseKeys.profilePhotoKey)
                        }
                    } else {
                        print("snapShot DNE error")
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.createNetworkAlert()
                    }
                    MBProgressHUD.hide(for: self.view, animated: true)
                    print("Dimiss VC")
                    self.navigationController?.popViewController(animated: true)
                }) { (error) in print(error.localizedDescription)}
            }
            })
        } else {
            createNetworkAlert()
        }
        
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerEditedImage] as! UIImage?
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    
    func uploadPicture(_ data: Data, completion:@escaping (_ url: String?) -> ()) {
        let storageRef = Storage.storage().reference()
        storageRef.child("image/profilePicture/\(self.uid)").putData(data, metadata: nil){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            }else{
                //store downloadURL
                completion((metaData?.downloadURL()?.absoluteString)!)
            }
        }
    }
    
    func handleTap(_ tapGesture: UITapGestureRecognizer) {
        let actionSheet = UIAlertController(title: "Upload Profile Picture", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title:"Choose from Album", style: .default, handler:{(action:UIAlertAction) in self.pickPhoto()}))
        
        actionSheet.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler:nil))
        self.present(actionSheet, animated: true, completion: nil)

    }
    
    func createNetworkAlert (){
        let alert = UIAlertController(title: "Photo upload failed", message: "Network connection error", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"Try again later", style: UIAlertActionStyle.default, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let actionSheet = UIAlertController(title: "Upload Profile Picture", message: nil, preferredStyle: .actionSheet)
//        
//        actionSheet.addAction(UIAlertAction(title:"Choose from Albumn", style: .default, handler:{(action:UIAlertAction) in self.pickPhoto()}))
//        
//        actionSheet.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler:nil))
//        self.present(actionSheet, animated: true, completion: nil)
//        
//    }
    
    func pickPhoto(){
        let imagePicker = UIImagePickerController()
        present(imagePicker, animated: true, completion: nil)
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
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
