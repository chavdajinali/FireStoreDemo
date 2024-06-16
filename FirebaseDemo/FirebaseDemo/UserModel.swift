//
//  UserModel.swift
//  FirebaseDemo
//
//  Created by Jinali Chavda on 07/06/24.
//

import Foundation
import Firebase
import FirebaseFirestore

struct UserModel : Codable {
    var userId:String?
    var userName:String?
    var email:String?
    var password:String?
    var categoryID:Int?
    var categoryName:String?
    var userProfileImage:String?
    
    init(document:QueryDocumentSnapshot) {
        self.userId = document.documentID
        self.userName = document.data()["userName"] as? String
        self.email = document.data()["email"] as? String
        self.password = document.data()["password"] as? String
        self.categoryID = document.data()["categoryID"] as? Int
        self.categoryName = document.data()["categoryName"] as? String
        self.userProfileImage = document.data()["userProfileImage"] as? String
    }
}

struct CategoryModel {
    var categoryID:Int?
    var categoryName:String?
    
    init(document:QueryDocumentSnapshot) {
        self.categoryID = document.data()["categoryID"] as? Int
        self.categoryName = document.data()["categoryName"] as? String
    }
}
