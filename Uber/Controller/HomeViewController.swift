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
    private let locationManager = CLLocationManager()
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()
        locationManagerDidChangeAuthorization(locationManager)
        
        view.backgroundColor = .red
        //        logOut()
    }
    
    // MARK:- Auth
    
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
        configureMapView()
        configureInputActivationView()
    }
    
    // MARK:- Private Helper Functions
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    private func configureInputActivationView() {
        inputActivationView.delegate = self
        
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 60, paddingLeft: 20, paddingRight: 20, height: 40)
        
        // Animate inputActivationView (fade in)
        inputActivationView.alpha = 0
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
    }
    
    private func configureLocationInputView() {
        locationInputView.delegate = self
        
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 200)
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.locationInputView.alpha = 1
        } completion: { _ in
            print("DEBUG: Present table view")
        }
    }
    
}

// MARK:- Location Manager Services

extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManager.delegate = self
        
        switch manager.authorizationStatus {
        case .notDetermined:
            print("DEBUG: Not determined")
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use")
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
}

// MARK:- Input Activation View Delegate Methods

extension HomeViewController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        configureLocationInputView()
        self.inputActivationView.alpha = 0
    }
    
}

// MARK:- Input View Delegate Methods

extension HomeViewController: LocationInputViewDelegate {
    func dismissLocationInputView() {
        UIView.animate(withDuration: 0.3) {
            self.locationInputView.alpha = 0
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
        }
    }
}



