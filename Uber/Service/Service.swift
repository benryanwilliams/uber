//
//  Service.swift
//  Uber
//
//  Created by Ben Williams on 16/01/2021.
//

import UIKit
import Firebase
import GeoFire

public let DB_REF = Database.database().reference()
public let REF_USERS = DB_REF.child("users")
public let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")
public let REF_TRIPS = DB_REF.child("trips")

struct Service {
    
    static let shared = Service()
    
    public func fetchUserData(uid: String, completion: @escaping(User) -> Void) {
        
        // Get dictionary containing the specified user's data from Firebase, create an instance of a User object using this, and once completed pass this to wherever the function fetchUserData gets called
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else { return }
            let user = User(uid: snapshot.key, dictionary: dictionary)
            completion(user)
        }
    }
    
    public func fetchDrivers(location: CLLocation, completion: @escaping(User) -> Void) {
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        
        REF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in
            geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { (uid, location) in
                fetchUserData(uid: uid) { (user) in
                    var driver = user
                    driver.location = location
                    completion(driver)
                    
                }
            })
        }
    }
    
    public func uploadTrip(_ pickupCoordinates: CLLocationCoordinate2D, _ destinationCoordinates: CLLocationCoordinate2D, completion: @escaping (Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let pickupArray = [pickupCoordinates.latitude, pickupCoordinates.longitude]
        let destinationArray = [destinationCoordinates.latitude, destinationCoordinates.longitude]
        
        let values = ["pickupCoordinates": pickupArray,
                      "destinationCoordinates": destinationArray,
                      "state": TripState.requested.rawValue] as [String : Any]
        
        REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
        
    }
}
