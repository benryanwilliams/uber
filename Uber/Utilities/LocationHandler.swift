//
//  LocationHandler.swift
//  Uber
//
//  Created by Ben Williams on 21/01/2021.
//

import CoreLocation

class LocationHandler: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationHandler()
    
    public var locationManager: CLLocationManager!
    public var location: CLLocation?
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
}
