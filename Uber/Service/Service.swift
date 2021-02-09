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
    
    /// Pass in uid to return User object via completion handler
    public func fetchUserData(uid: String, completion: @escaping(User) -> Void) {
        
        // Get dictionary containing the specified user's data from Firebase, create an instance of a User object using this, and once completed pass this to wherever the function fetchUserData gets called
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else { return }
            let user = User(uid: snapshot.key, dictionary: dictionary)
            completion(user)
        }
    }
    
    /// Pass in user's location and return drivers within radius of 50 kilometres of the user
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
    
    /// Pass in pickup and destination coordinates and add the trip based on these to the databse. Once uploaded, the results can be also be used via the completion block.
    public func uploadTrip(_ pickupCoordinates: CLLocationCoordinate2D, _ destinationCoordinates: CLLocationCoordinate2D, completion: @escaping (Error?, DatabaseReference) -> Void) {
        // 1) Get uid of current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // 2) Create arrays from the coordinates passed into the method
        let pickupArray = [pickupCoordinates.latitude, pickupCoordinates.longitude]
        let destinationArray = [destinationCoordinates.latitude, destinationCoordinates.longitude]
        
        // 3) Create values dictionary to be uploaded to Firebase
        let values = ["pickupCoordinates": pickupArray,
                      "destinationCoordinates": destinationArray,
                      "state": TripState.requested.rawValue] as [String : Any]
        
        // 4) Upload to Firebase, within 'trips', with the uid as the first child, then add the values dictionary beneath this, then once this has been completed run the completion block
        REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
        
    }
    
    /// When new child added to 'trips' within Firebase, create a new instance of a Trip based on this to be used via the completion handler
    public func observeTrips(completion: @escaping (Trip) -> Void) {
        REF_TRIPS.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else { return }
            let uid = snapshot.key
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
        }
    }
    
    public func observeTripCancelled(trip: Trip, completion: @escaping() -> Void) {
        REF_TRIPS.child(trip.passengerUid).observeSingleEvent(of: .childRemoved) { (snapshot) in
            completion()
        }
    }
    
    /// Pass in instance of Trip, update with driverUid, change state to accepted then update Firebase with this
    public func acceptTrip(trip: Trip, completion: @escaping (Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let values = ["driverUid": uid, "state": TripState.accepted.rawValue] as [String: Any]
        REF_TRIPS.child(trip.passengerUid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    /// When the current user's 'trips' data changes within Firebase, return the new trip (assign it using the completion handler)
    public func observeCurrentTrip(completion: @escaping (Trip) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_TRIPS.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
        }
    }
    
    /// Remove Trip relating to the current user from Firebase
    public func cancelTrip(completion: @escaping (Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_TRIPS.child(uid).removeValue(completionBlock: completion)
        
    }
    
    /// Add driver location to Firebase when location changes
    public func updateDriverLocation(location: CLLocation) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        geofire.setLocation(location, forKey: uid)
    }
}
