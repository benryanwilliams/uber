//
//  Trip.swift
//  Uber
//
//  Created by Ben Williams on 28/01/2021.
//

import CoreLocation

// Declared as type Int, so that requested = 0, accepted = 1, inProgress = 2, completed = 3
enum TripState: Int {
    case requested
    case accepted
    case inProgress
    case completed
}

struct Trip {
    var pickupCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var passengerUid: String!
    var driverUid: String?
    var state: TripState!
    
    // Pass in passenger uid and dictionary when trip instance initialised to populate the properties
    init(passengerUid: String, dictionary: [String: Any]) {
        self.passengerUid = passengerUid
        
        if let pickupCoordinates = dictionary["pickupCoordinates"] as? NSArray {
            guard let lat = pickupCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = pickupCoordinates[1] as? CLLocationDegrees else { return }
            self.pickupCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let destinationCoordinates = dictionary["destinationCoordinates"] as? NSArray {
            guard let lat = destinationCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = destinationCoordinates[1] as? CLLocationDirection else { return }
            self.destinationCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        self.driverUid = dictionary["driverUid"] as? String ?? ""
        
        if let state = dictionary["state"] as? Int {
            self.state = TripState(rawValue: state)
        }
    }
}


