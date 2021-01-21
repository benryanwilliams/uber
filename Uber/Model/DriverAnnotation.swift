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
    
    init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
    public func updateAnnotationPosition(withCoordinate coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coordinate
        }
    }
    
}
