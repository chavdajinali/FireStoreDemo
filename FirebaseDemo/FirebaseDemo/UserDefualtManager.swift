//
//  UserDefualtManager.swift
//  FirebaseDemo
//
//  Created by Jinali Chavda on 10/06/24.
//

import Foundation

class UserDefaultsManager {
    
    static func saveData<T:Codable>(model:T,key:String) {
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(model) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }else {
            debugPrint("User defaluts not save")
        }
    }
    
    static func getData<T:Codable>(key:String) -> T? {
        if let savedPerson = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(T.self, from: savedPerson)
                return response
            }catch {
                debugPrint("Get Data failed",error.localizedDescription)
                return nil
            }
           // return try! decoder.decode(T.self, from: savedPerson)
        }else {
            return nil
        }
    }
}
