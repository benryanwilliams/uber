//
//  Service.swift
//  Uber
//
//  Created by Ben Williams on 16/01/2021.
//

import UIKit
import Firebase

private let DB_REF = Database.database().reference()
private let REF_USERS = DB_REF.child("users")

struct Service {
    
    static let shared = Service()
    
    public func fetchUserData(completion: @escaping(User) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        
        REF_USERS.child(currentUserID).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else { return }
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
}
