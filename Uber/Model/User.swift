//
//  User.swift
//  Uber
//
//  Created by Ben Williams on 16/01/2021.
//

import CoreLocation

enum AccountType: Int {
    case passenger
    case driver
}

struct User {
    public var accountType: AccountType!
    public let email: String
    public let name: String
    public var location: CLLocation?
    public let uid: String
    
    // When creating a User, pass in a dictionary (from the database), which will populate the attributes of the user
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.email = dictionary["email"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        
        if let accountType = dictionary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: accountType)
        }
    }
    
}
