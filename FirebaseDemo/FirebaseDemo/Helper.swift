//
//  Helper.swift
//  FirebaseDemo
//
//  Created by Jinali Chavda on 07/06/24.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

let APP_NAME = "FireStore Demo"
let appdelegate = UIApplication.shared.delegate 

final class Helper {
    
    static let shared = Helper()
    
    let db = Firestore.firestore()
    let firestorage = Storage.storage()
    
    private init() {
        
    }
    
}

extension UIViewController {
    func showAlert(_ message:String?) {
        
        let alert: UIAlertController = UIAlertController.init(title: APP_NAME, message: message ?? "", preferredStyle: .alert)
        let hideAction: UIAlertAction = UIAlertAction.init(title: "Ok", style: .default, handler: nil)
        alert.addAction(hideAction)
        self.present(alert, animated: true, completion: nil)
        
    }
}
