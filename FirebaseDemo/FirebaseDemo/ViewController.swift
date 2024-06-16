//
//  ViewController.swift
//  FirebaseDemo
//
//  Created by Jinali Chavda on 07/06/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class ViewController: UIViewController {
    
    @IBOutlet weak var userNameTextFiled:UITextField!
    @IBOutlet weak var userEmailTextFiled:UITextField!
    @IBOutlet weak var userPassword:UITextField!
    
    @IBOutlet weak var viewCategory: UIView!
    @IBOutlet weak var userCategoryTextFiled: UITextField!
    @IBOutlet weak var userProfileImgView:UIImageView!
    @IBOutlet weak var editUserProfile: UIButton!
    
    var profileImageStr = ""
    var isFromEdit = false
    var user:UserModel?
    var categoryList:[CategoryModel] = []
    var selectedCategoryId : Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            await getCategoryList()
        }
        
        if isFromEdit {
            userPassword.isUserInteractionEnabled = false
            getEditableData()
        }
        
    }

    func getCategoryList() async {
        categoryList.removeAll()
        do {
            let snapshot = try await Helper.shared.db.collection("Category").getDocuments()
            for document in snapshot.documents {
                categoryList.append(CategoryModel(document: document))
            }
            print(categoryList)
        } catch {
          print("Error getting documents: \(error)")
        }
    }
    
    func showCategories(){
        let alert = UIAlertController(title: "Categories", message: "Choose Categories", preferredStyle: UIAlertController.Style.actionSheet)
        for obj in categoryList {
            let action = UIAlertAction(title: obj.categoryName, style: UIAlertAction.Style.default) { [weak self] action in
                self?.userCategoryTextFiled.text = obj.categoryName
                self?.selectedCategoryId = obj.categoryID
            }
            alert.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { action in
            
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func getEditableData(){
        getImage(str: user?.userProfileImage ?? "")
        userNameTextFiled.text = "\(user?.userName ?? "")"
        userEmailTextFiled.text = "\(user?.email ?? "")"
        userPassword.text = user?.password ?? ""
        if user?.categoryName == "" {
            userCategoryTextFiled.placeholder = "Choose Category"
        }else {
            userCategoryTextFiled.text = user?.categoryName ?? ""
        }
    }
    
    func getImage(str:String){
        if str == "" { return }
        let storageRef = Helper.shared.firestorage.reference().child(str)
        storageRef.getData(maxSize: (1024*1024)) { data, error in
            if error == nil {
                if let image = UIImage(data: data!) {
                    self.userProfileImgView.image = image
                }
            }
        }
    }
    
    @IBAction func clickedSubmitButton(_ sender: UIButton) {
        if userNameTextFiled.text != "" && userEmailTextFiled.text != "" && userPassword.text != "" {
            if isFromEdit {
                updateUserNameData()
            }else {
                addDataToFirestoreUserTable()
            }
        }else{
            var validationMessage = ""
            if userNameTextFiled.text != "" {
                validationMessage += "\nPlease Enter Name"
            }else if userEmailTextFiled.text != "" {
                validationMessage += "\nPlesae Enter Email"
            }else if userPassword.text != "" {
                validationMessage += "\nPlease Enter Password"
            }
            if validationMessage != "" {
                showAlert(validationMessage)
            }
        }
    }
    
    @IBAction func ClickedShowAllUserList(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "UsersListVC") as! UsersListVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func categoryTapped(_ sender: UIButton) {
        showCategories()
    }
    
    @IBAction func openImagePicker(_ sender: UIButton) {
        showImagePickerOptions()
    }
    
    func updateUserNameData() {
        var param = ["userName":userNameTextFiled.text ?? "","email":userEmailTextFiled.text ?? ""] as [String:Any]
        
        if userCategoryTextFiled.text != "" {
            param["categoryID"] = selectedCategoryId ?? 0
            param["categoryName"] = userCategoryTextFiled.text ?? ""
        }
        
        let userRef = Helper.shared.db.collection("User").document(user?.userId ?? "")

        userRef.updateData(param) { [weak self] error in
            if error == nil {
                Task {
                    self?.navigationController?.popViewController(animated: true)
                }
            }else{
                self?.showAlert("No Data Found")
            }
        }

    }
    
    func addDataToFirestoreUserTable() {
        do {
            let ref = try  Helper.shared.db.collection("User").addDocument(data: [
                "userName": userNameTextFiled.text ?? "",
                "email": userEmailTextFiled.text ?? "",
                "password": userPassword.text ?? "",
                "userProfileImage" : profileImageStr
            ])
            print("Document added with ID: \(ref.documentID)")
            self.navigationController?.popViewController(animated: true)
        } catch {
          print("Error adding document: \(error)")
        }
    }
    
    func imagePicker(sourceType:UIImagePickerController.SourceType) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        return imagePicker
    }
    func showImagePickerOptions() {
        let alertVC = UIAlertController(title: "Pick Profile Photo", message: "Choose a Picture from Library or camera", preferredStyle: UIAlertController.Style.actionSheet)
        
        //ImagePicker for camera
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) { [weak self] action in
            guard let self = self else {
                return
            }
            let cameraImagePicker = self.imagePicker(sourceType: .camera)
            self.present(cameraImagePicker, animated: true)
        }
        
        //ImagePicker for Library
        let LibraryAction = UIAlertAction(title: "Photos", style: UIAlertAction.Style.default) { [weak self] action in
            guard let self = self else {
                return
            }
            let LibraryImagePicker = self.imagePicker(sourceType: .photoLibrary)
            self.present(LibraryImagePicker, animated: true)
        }
        
        //ImagePicker for Library
        let CancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { action in
           
        }
        alertVC.addAction(cameraAction)
        alertVC.addAction(LibraryAction)
        alertVC.addAction(CancelAction)
        self.present(alertVC, animated: true)
    }
    
    func uploadMedia(str:String,completion: @escaping (_ url: String?) -> Void) {
        
        ImageDownloader.shared.imageCache.removeObject(forKey:str as AnyObject)
        
        let storageRef = Helper.shared.firestorage.reference().child(str)
        if let uploadData = self.userProfileImgView.image!.pngData() {
            storageRef.putData(uploadData) { metaData, error in
                if error != nil {
                    print("error")
                    completion(nil)
                } else {
                    completion(metaData?.path)
                }
            }
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == userPassword {
            userPassword.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate  {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            userProfileImgView.image = image
            var imgstr = "UserImages/\(Date().timeIntervalSince1970).png"
            if isFromEdit {
                imgstr = user?.userProfileImage ?? ""
            }
            uploadMedia(str: imgstr) { url in
                self.profileImageStr = url ?? ""
            }
        }
        self.dismiss(animated: true)
    }
    
}

