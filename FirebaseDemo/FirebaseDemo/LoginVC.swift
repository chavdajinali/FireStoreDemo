//
//  LoginVC.swift
//  FirebaseDemo
//
//  Created by Jinali Chavda on 07/06/24.
//

import UIKit

class LoginVC: UIViewController {
    
    
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    @IBAction func clicked_Login(_ sender: UIButton) {
        findUser()
    }
    
    func findUser() {
        let ref = Helper.shared.db.collection("User")
        let query = ref.whereField("email", isEqualTo: userEmailTextField.text ?? "")
            .whereField("password", isEqualTo: userPasswordTextField.text ?? "").limit(to: 1)
        
        query.getDocuments { snapshot, error in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            guard let docs = snapshot?.documents else { return }
            if docs.count == 0 {
                self.showAlert("No User Found.")
            }else{
                for doc in docs {
                    let user = UserModel(document: doc)
                    UserDefaultsManager.saveData(model: user, key: "UserData")
                    
                    let vc = self.storyboard?.instantiateViewController(identifier: "UsersListVC") as! UsersListVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
}
