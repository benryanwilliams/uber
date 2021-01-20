//
//  User.swift
//  Uber
//
//  Created by Ben Williams on 16/01/2021.
//

import Foundation

struct User {
    public let accountType: Int
    public let email: String
    public let name: String
    
    // When creating a User, pass in a dictionary (from the database), which will populate the attributes of the user
    init(dictionary: [String: Any]) {
        self.accountType = dictionary["accountType"] as? Int ?? 0
        self.email = dictionary["email"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
    }
    
}
