//
//  DriverAnnotation.swift
//  Uber
//
//  Created by Ben Williams on 21/01/2021.
//

import MapKit

class DriverAnnotation: NSObject, MKAnnotation {
    
    static let identifier = "driverAnnotation"
    
    var uid: String
    dynamic var coordinate: CLLocationCoordinate2D
    
    // Pass in the driver uid and coordinate when initialising a new driver annotation
    init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
    // Animate the coordinate to the new position when this function is called
    public func updateAnnotationPosition(withCoordinate coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coordinate
        }
    }
    
}
