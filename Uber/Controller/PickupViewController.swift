//
//  PickupViewController.swift
//  Uber
//
//  Created by Ben Williams on 29/01/2021.
//

import UIKit
import MapKit

protocol PickupViewControllerDelegate: AnyObject {
    func didAcceptTrip(trip: Trip)
}

class PickupViewController: UIViewController {
    
    // MARK:- Properties
    
    weak var delegate: PickupViewControllerDelegate?
    
    private var trip: Trip
    private let mapView = MKMapView()
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return button
    }()
    
    private let pickupLabel: UILabel = {
        let label = UILabel()
        label.text = "Would you like to pick up this passenger?"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let acceptButton: UIButton = {
        let button = UIButton()
        button.setTitle("ACCEPT TRIP", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.backgroundColor, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(didTapAcceptButton), for: .touchUpInside)
        return button
    }()
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMapView()
    }
    
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Selectors
    
    @objc func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapAcceptButton() {
        Service.shared.acceptTrip(trip: trip) { (error, ref) in
            self.delegate?.didAcceptTrip(trip: self.trip)
            
        }
    }
    
    
    // MARK:- Helper Functions
    
    private func configureUI() {
        view.backgroundColor = .backgroundColor
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingLeft: 16, width: 24, height: 24)
        
        view.addSubview(mapView)
        let mapViewSize: CGFloat = 270
        mapView.centerX(inView: view)
        mapView.centerY(inView: view, constant: -200)
        mapView.setDimensions(height: mapViewSize, width: mapViewSize)
        mapView.layer.cornerRadius = mapViewSize / 2
        
        view.addSubview(pickupLabel)
        pickupLabel.anchor(top: mapView.bottomAnchor, paddingTop: 16)
        pickupLabel.centerX(inView: view)
        
        view.addSubview(acceptButton)
        acceptButton.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                            paddingTop: 16, paddingLeft: 32, paddingRight: 32, height: 50)
        
    }
    
    private func configureMapView() {
        let region = MKCoordinateRegion(center: trip.pickupCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.region = region
        
        let anno = MKPointAnnotation()
        anno.coordinate = trip.pickupCoordinate
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true)
    }
    
}
