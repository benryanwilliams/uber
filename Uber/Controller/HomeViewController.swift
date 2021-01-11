//
//  HomeViewController.swift
//  Uber
//
//  Created by Ben Williams on 11/01/2021.
//

import UIKit
import Firebase
import MapKit

class HomeViewController: UIViewController {

    // MARK:- Properties
    
    private let mapView = MKMapView()
    
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()

        view.backgroundColor = .red
//        logOut()
    }
    
    // MARK:- API
    
    private func checkIfUserLoggedIn() {
        if Auth.auth().currentUser == nil {
            // User is not logged in
            print("DEBUG: User is not logged in")
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginViewController())
                nav.isModalInPresentation = true
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            // User is logged in
            configureUI()
        }
        
    }
    
    private func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: Error signing user out: \(error)")
        }
    }
    
    // MARK:- Public Helper Functions
    
    public func configureUI() {
        view.addSubview(mapView)
        mapView.frame = view.frame
    }
    
    // MARK:- Private Helper Functions
    
}
