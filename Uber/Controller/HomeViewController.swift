//
//  HomeViewController.swift
//  Uber
//
//  Created by Ben Williams on 11/01/2021.
//

import UIKit
import Firebase
import MapKit

private enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

class HomeViewController: UIViewController {
    
    // MARK:- Properties
    
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let rideActionView = RideActionView()
    private let rideActionViewHeight: CGFloat = 300
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let locationInputViewHeight: CGFloat = 200
    private var searchResults = [MKPlacemark]()
    private var actionButtonConfig = ActionButtonConfiguration()
    private var route: MKRoute?
    
    private let tableView = UITableView()
    
    private var user: User? {
        didSet {
            locationInputView.user = user
            if user?.accountType == .passenger {
                fetchDrivers()
                configureInputActivationView()
                observeCurrentTrip()
            } else {
                observeTrips()
                
            }
        }
    }
    
    private var trip: Trip? {
        didSet {
            guard let user = user else { return }
            
            if user.accountType == .driver {
                guard let trip = trip else { return }
                let vc = PickupViewController(trip: trip)
                vc.delegate = self
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
            } else {
                print("Show ride action for accepted trip")
            }
            
        }
    }
    
    private let actionButton: UIButton = {
       let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        return button
    }()
    
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()
        locationManagerDidChangeAuthorization(locationManager!)
//        logOut()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let trip = trip else { return }
        print("DEBUG: Trip state is \(trip.state)")
    }
    
    // MARK:- Selectors
    
    @objc private func didTapActionButton() {
        switch actionButtonConfig {
        case .showMenu:
            print("Show menu")
        case .dismissActionView:
            removeAnnotationsAndOverlays()
            mapView.showAnnotations(mapView.annotations, animated: true)

            UIView.animate(withDuration: 0.3) {
                self.configureActionButtonState(config: .showMenu)
                self.inputActivationView.alpha = 1
                self.animateRideActionView(shouldShow: false)
            }
        }
    }
    
    // MARK:- API
    
    private func observeCurrentTrip() {
        Service.shared.observeCurrentTrip { (trip) in
            self.trip = trip
            
            if trip.state == .accepted {
                self.shouldPresentLoadingView(false)
                guard let driverUid = trip.driverUid else { return }
                
                Service.shared.fetchUserData(uid: driverUid) { (driver) in
                    self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: driver)

                }
                
            }
        }
    }
    
    private func observeTrips() {
        Service.shared.observeTrips { (trip) in
            self.trip = trip
        }
    }
    
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
    }
    
    public func configureUI() {
        configureMapView()
        configureActionButton()
        configureTableView()
        configureRideActionView()
    }
    
    // MARK:- Private Helper Functions
    
    private func animateRideActionView(shouldShow: Bool, destination: MKPlacemark? = nil, config: RideActionViewConfiguration? = nil, user: User? = nil) {
        let yOrigin = shouldShow ? self.view.frame.height - rideActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
            
        }
        
        if shouldShow {
            guard let config = config else { return }
            
            if let destination = destination {
                rideActionView.destination = destination
            }
            
            if let user = user {
                rideActionView.user = user
            }
            
            rideActionView.configureUI(withConfig: config)
        }
        
        
    }
    
    private func configureActionButton() {
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
                            paddingTop: 16, paddingLeft: 16, width: 30, height: 30)
    }
    
    private func configureActionButtonState(config: ActionButtonConfiguration) {
        switch config {
        case .showMenu:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
        case .dismissActionView:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp-1").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .dismissActionView
        }
    }
    
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
        inputActivationView.anchor(top: actionButton.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 18, paddingLeft: 20, paddingRight: 20, height: 40)
        
        // Animate inputActivationView (fade in)
        inputActivationView.alpha = 0
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
    }
    
    private func configureLocationInputView() {
        locationInputView.delegate = self
        
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: locationInputViewHeight)
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
    
    private func configureRideActionView() {
        rideActionView.delegate = self
        view.addSubview(rideActionView)
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: rideActionViewHeight)
    }
    
    private func dismissInputView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
        }, completion: completion)
    }
    
    private func removeAnnotationsAndOverlays() {
        mapView.annotations.forEach { annotation in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    
}

// MARK:- MapView Functions

extension HomeViewController: MKMapViewDelegate {
    
    private func generatePolyline(toDestination destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else { return }
            print("Response is \(response)")
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else { return }
            print("Polyline is \(polyline)")
            self.mapView.addOverlay(polyline)
            
        }
    }
    
    private func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()
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
            self.searchResults = results
            self.tableView.reloadData()
        }
        
    }
    
    func dismissLocationInputView() {
        dismissInputView()
        UIView.animate(withDuration: 0.5) {
            self.inputActivationView.alpha = 1
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = self.searchResults[indexPath.row]
        
        configureActionButtonState(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: selectedPlacemark)
        self.generatePolyline(toDestination: destination)
        
        self.dismissInputView { _ in
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            
            // Adds only non-driver annotations to 'annotations' array
            let annotations = self.mapView.annotations.filter({!$0.isKind(of: DriverAnnotation.self)})
            self.mapView.zoomToFit(annotations: annotations) // Zooms in on these annotations only
            
            self.animateRideActionView(shouldShow: true, destination: selectedPlacemark, config: .requestRide)
        }
    }
}

// MARK:- RideActionViewDelegate

extension HomeViewController: RideActionViewDelegate {
    public func cancelTrip() {
        Service.shared.cancelTrip { (error, ref) in
            if let error = error {
                print("DEBUG: Error cancelling trip: \(error)")
            } else {
                self.animateRideActionView(shouldShow: false)
            }
        }
    }
    
    public func uploadTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate else { return }
        guard let destinationCoordinates = view.destination?.coordinate else { return }
        
        shouldPresentLoadingView(true, message: "Finding you a ride...")
        
        Service.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (error, ref) in
            if let err = error {
                print("DEBUG: Error uploading trip: \(err)")
                return
            }
            
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
            
            
        }
    }
    
    
}

// MARK:- PickupViewControllerDelegate

extension HomeViewController: PickupViewControllerDelegate {
    func didAcceptTrip(trip: Trip) {
        let anno = MKPointAnnotation()
        anno.coordinate = trip.pickupCoordinate
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true)
        
        let placemark = MKPlacemark(coordinate: trip.pickupCoordinate)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyline(toDestination: mapItem)
        
        mapView.zoomToFit(annotations: mapView.annotations)
        
        Service.shared.observeTripCancelled(trip: trip) {
            self.removeAnnotationsAndOverlays()
            self.animateRideActionView(shouldShow: false)
        }
        
        self.dismiss(animated: true) {
            Service.shared.fetchUserData(uid: trip.passengerUid) { (passenger) in
                self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: passenger)

            }
        }
        
    }
    
    
}



