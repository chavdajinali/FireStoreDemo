//
//  UsersListVC.swift
//  FirebaseDemo
//
//  Created by Jinali Chavda on 07/06/24.
//

import UIKit
import FirebaseStorage

class UsersListVC: UIViewController {
    
    @IBOutlet weak var tblUserList : UITableView!
    
    @IBOutlet weak var updateDeleteBgView: UIView!
    
    @IBOutlet weak var userNameTextField: UITextField!
   
    
    var users:[UserModel] = []
    var categoryList:[CategoryModel] = []
    var selectIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateDeleteBgView.isHidden = true
        Task {
            await getAllUserList()
        }
    }
    
    @IBAction func ClickedUpdateButton(_ sender: UIButton) {
        updateUserNameData()
        DismissTapped(nil)
    }
    
    @IBAction func ClickedDeleteButton(_ sender: UIButton) {
        Task {
            await deleteUserData()
        }
        DismissTapped(nil)
    }
    
    @IBAction func DismissTapped(_ sender: UIButton?) {
        updateDeleteBgView.isHidden = true
        self.view.endEditing(true)
    }
    
    @IBAction func clickedAddUser(_ sender:UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "ViewController") as! ViewController
        vc.isFromEdit = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickedChat(_ sender:UIButton) {
        
    }
    
    @IBAction func ClickedProfile(_ sender:UIButton) {
        let userData:UserModel? = UserDefaultsManager.getData(key: "UserData")
        let vc = self.storyboard?.instantiateViewController(identifier: "UserProfileVC") as! UserProfileVC
        vc.user = userData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func Clicked_AssignCategory(_ sender: UIButton?) {
        Task {
            await getCategoryList()
        }
        self.view.endEditing(true)
    }
    
    
    func getCategoryList() async {
        categoryList.removeAll()
        do {
            let snapshot = try await Helper.shared.db.collection("Category").getDocuments()
            for document in snapshot.documents {
                categoryList.append(CategoryModel(document: document))
            }
            showCategories()
            print(categoryList)
        } catch {
          print("Error getting documents: \(error)")
        }
    }
    
    func showCategories(){
        let alert = UIAlertController(title: "Categories", message: "Choose Categories", preferredStyle: UIAlertController.Style.actionSheet)
        for obj in categoryList {
            let action = UIAlertAction(title: obj.categoryName, style: UIAlertAction.Style.default) { [weak self] action in
                self?.updateUserCategoryData(category: obj)
                self?.DismissTapped(nil)
            }
            alert.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { action in
            
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func updateUserCategoryData(category:CategoryModel) {
        let userRef = Helper.shared.db.collection("User").document(users[selectIndex].userId ?? "")
        
        userRef.updateData(["categoryID":category.categoryID ?? 0,"categoryName":category.categoryName ?? ""]) { [weak self] error in
            if error == nil {
                Task {
                    await self?.getAllUserList()
                }
            }else{
                self?.showAlert("No Data Found")
            }
        }

    }
    
    func updateUserNameData() {
        let userRef = Helper.shared.db.collection("User").document(users[selectIndex].userId ?? "")
        
        userRef.updateData(["userName":userNameTextField.text ?? ""]) { [weak self] error in
            if error == nil {
                Task {
                    await self?.getAllUserList()
                }
            }else{
                self?.showAlert("No Data Found")
            }
        }

    }
    

    func getAllUserList() async {
        users.removeAll()
        do {
            let snapshot = try await Helper.shared.db.collection("User").getDocuments()
          for document in snapshot.documents {
              users.append(UserModel(document: document))
          }
            tblUserList.reloadData()
            print(users)
        } catch {
          print("Error getting documents: \(error)")
        }
    }
    
    func deleteUserData() async{
        do {
            try await Helper.shared.db.collection("User").document(users[selectIndex].userId ?? "").delete()
            await self.getAllUserList()
            print("Document successfully removed!")
        } catch {
            print("Error removing document: \(error)")
        }
    }
    
    func deleteUserProfileImage() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let desertRef = storageRef.child(users[selectIndex].userProfileImage ?? "")
        
        desertRef.delete { error in
            if let error = error {
                print(error.localizedDescription)
            }else{
                Task{
                    await self.deleteUserData()
                }
            }
        }
        
    }

}

extension UsersListVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tblUserList.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        cell.configureCell(user: users[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let accept = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, nil) in
            let vc = self?.storyboard?.instantiateViewController(identifier: "ViewController") as! ViewController
            vc.isFromEdit = true
            vc.user = self?.users[indexPath.row]
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        accept.image = UIImage(systemName: "Pencil")
        return UISwipeActionsConfiguration(actions: [accept])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        selectIndex = indexPath.row
        let delete = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, nil) in
            self?.deleteUserProfileImage()
        }
        return UISwipeActionsConfiguration(actions: [delete])
        
    }
    
}

class UserCell : UITableViewCell {
    
    @IBOutlet weak var userNameLabel:UILabel!
    @IBOutlet weak var userEmailLabel:UILabel!
    @IBOutlet weak var userCategory:UILabel!
    @IBOutlet weak var userProfileImage:UIImageView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        userNameLabel.text = "User Name :"
        userEmailLabel.text = "User Email :"
        userCategory.text = "Category :"
        userProfileImage.image = UIImage(systemName:"person.circle.fill")
    }
    
    func configureCell(user:UserModel){
        userNameLabel.text = "User Name : \(user.userName ?? "")"
        userEmailLabel.text = "User Email : \(user.email ?? "")"
        userCategory.text = "Category : \(user.categoryName ?? "")"
        
        ImageDownloader.shared.downloadImage(imgstr: user.userProfileImage ?? "") { [weak self] image in
            self?.userProfileImage.image = image
        }
        
    }
    
}

extension UsersListVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userNameTextField.resignFirstResponder()
    }
}
