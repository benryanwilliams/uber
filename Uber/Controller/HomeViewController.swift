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
    private let locationManager = LocationHandler.shared.locationManager
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private var searchResults = [MKPlacemark]()
    
    private let tableView = UITableView()
    
    private var user: User? {
        didSet {
            locationInputView.user = user
        }
    }
    
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()
        locationManagerDidChangeAuthorization(locationManager!)
        
    }
    
    // MARK:- API
    
    private func fetchUserData() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: currentUserId) { user in
            self.user = user
        }
        
    }
    
    // N.B. Service.shared.fetchDrivers automatically gets called every time the location of the driver changes since it is observing the database via geofire (see definition of this within Service.swift)
    private func fetchDrivers() {
        guard let location = locationManager?.location else { return }
        Service.shared.fetchDrivers(location: location) { (driver) in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains { annotation -> Bool in
                    guard let driverAnnotation = annotation as? DriverAnnotation else { return false }
                    if driverAnnotation.uid == driver.uid {
                        // Driver is already visible - update driver location whenever this function is called
                        driverAnnotation.updateAnnotationPosition(withCoordinate: coordinate)
                        return true
                    }
                    
                    // Driver is not visible
                    return false
                }
                
            }
            
            // If driver is not visible then add to map
            if !driverIsVisible {
                self.mapView.addAnnotation(annotation)
            }
            
            
        }
    }
    
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
            configure()
        }
        
    }
    
    private func logOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginViewController())
                nav.isModalInPresentation = true
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } catch {
            print("DEBUG: Error signing user out: \(error)")
        }
    }
    
    // MARK:- Public Helper Functions
    
    public func configure() {
        configureUI()
        fetchUserData()
        fetchDrivers()
    }
    
    public func configureUI() {
        configureMapView()
        configureInputActivationView()
        configureTableView()
    }
    
    // MARK:- Private Helper Functions
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.delegate = self
        
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
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = self.locationInputView.frame.height
            }
        }
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.identifier)
        
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputView.frame.height
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
    }
    
}

// MARK:- MapView Delegate Functions

extension HomeViewController: MKMapViewDelegate {
    
    public func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            
            response.mapItems.forEach { (item) in
                results.append(item.placemark)
            }
            completion(results)
        }
        
    }
    
    // Change driver annotation appearance to Uber arrow
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: DriverAnnotation.identifier)
            view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            return view
        }
        return nil
    }
}

// MARK:- Location Manager Services

extension HomeViewController {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .notDetermined:
            print("DEBUG: Not determined")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use")
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
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
    func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { (results) in
            print("DEBUG: Placemarks are \(results)")
            self.searchResults = results
            self.tableView.reloadData()
        }
        
    }
    
    func dismissLocationInputView() {
        UIView.animate(withDuration: 0.3) {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
        } completion: { _ in
            self.locationInputView.removeFromSuperview()
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
        }
    }
}

// MARK:- TableView Delegate and Datasource Methods

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "test"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.identifier, for: indexPath) as! LocationTableViewCell
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row]
        }
        return cell
    }
    
    
}



