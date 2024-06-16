//
//  UserProfileVC.swift
//  FirebaseDemo
//
//  Created by Jinali Chavda on 10/06/24.
//

import UIKit

class UserProfileVC: UIViewController {

    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var userProfileLabel:UILabel!
    @IBOutlet weak var userProfileEmail:UILabel!
    @IBOutlet weak var userProfileCategory:UILabel!
    
    var user:UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getImage(str: user?.userProfileImage ?? "")

        userProfileLabel.text = "User Name: \(user?.userName ?? "")"
        userProfileEmail.text = "User Email: \(user?.email ?? "")"
        userProfileCategory.text = "User Category: \(user?.categoryName ?? "")"
    }
    
    func getImage(str:String){
        let storageRef = Helper.shared.firestorage.reference().child(str)
        storageRef.getData(maxSize: (1024*1024)) { data, error in
            if error == nil {
                if let image = UIImage(data: data!) {
                    self.profileImage.image = image
                }
            }
        }
    }
    
    @IBAction func clickedLogout(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "UserData")
        let vc = self.storyboard?.instantiateViewController(identifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
