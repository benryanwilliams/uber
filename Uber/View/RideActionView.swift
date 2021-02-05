//
//  RideActionView.swift
//  Uber
//
//  Created by Ben Williams on 27/01/2021.
//

import UIKit
import MapKit

protocol RideActionViewDelegate: AnyObject {
    // Pass in class so we have access to properties and functions from class
    func uploadTrip(_ view: RideActionView)
}

enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case pickupPassenger
    case tripInProgress
    case endTrip
    
    init() {
        self = .requestRide
    }
}

enum ButtonAction: CustomStringConvertible {
    case requestRide
    case cancel
    case getDirections
    case pickup
    case dropoff
    
    var description: String {
        switch self {
        case .requestRide: return "CONFIRM UBERX"
        case .cancel: return "CANCEL RIDE"
        case .getDirections: return "GET DIRECTIONS"
        case .pickup: return "PICKUP PASSENGER"
        case .dropoff: return "DROP OFF PASSENGER"
        }
    }
    
    init() {
        self = .requestRide
    }
}

class RideActionView: UIView {
    
    // MARK:- Properties
    
    weak var delegate: RideActionViewDelegate?
    var config = RideActionViewConfiguration()
    var buttonAction = ButtonAction()
    var user: User?
    
    public var destination: MKPlacemark? {
        didSet {
            self.titleLabel.text = destination?.name
            self.addressLabel.text = destination?.address
        }
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let addressLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var infoView: UIView = {
       let view = UIView()
        view.backgroundColor = .black
        
        view.addSubview(infoViewLabel)
        infoViewLabel.centerX(inView: view)
        infoViewLabel.centerY(inView: view)
        
        return view
    }()
    
    private let infoViewLabel: UILabel = {
        let label = UILabel()
        label.text = "X"
        label.font = .systemFont(ofSize: 30)
        label.textColor = .white
        return label
    }()
    
    private let uberInfoLabel: UILabel = {
       let label = UILabel()
        label.text = "UberX"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.setTitle("CONFIRM UBERX", for: .normal)
        button.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        return button
    }()
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        
        addSubview(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 16)
        
        addSubview(infoView)
        let size: CGFloat = 60
        infoView.anchor(top: stack.bottomAnchor, paddingTop: 16, width: size, height: size)
        infoView.centerX(inView: self)
        infoView.layer.cornerRadius = size/2
        
        addSubview(uberInfoLabel)
        uberInfoLabel.anchor(top: infoView.bottomAnchor, left: leftAnchor, right: rightAnchor)
        
        addSubview(separatorLine)
        separatorLine.anchor(top: uberInfoLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8, height: 0.75)
        
        configureConfirmButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Helper Functions
    
    private func configureConfirmButton() {
        addSubview(actionButton)
        actionButton.anchor(top: separatorLine.bottomAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 16, paddingLeft: 12, paddingBottom: 12, paddingRight: 12, height: 60)
    }
    
    // MARK:- Selectors
    
    @objc private func didTapActionButton() {
        switch buttonAction {
        
        case .requestRide:
            delegate?.uploadTrip(self)
        case .cancel:
            print("DEBUG: Cancel tapped")
        case .getDirections:
            print("DEBUG: Handle get directions")
        case .pickup:
            print("DEBUG: Handle pickup")
        case .dropoff:
            print("DEBUG: Handle dropoff")

        }
    }
    
    // MARK:- Helper Functions
    
    public func configureUI(withConfig config: RideActionViewConfiguration) {
        switch config {
        case .requestRide:
            buttonAction = .requestRide
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripAccepted:
            guard let otherUser = user else { return }
            
            if otherUser.accountType == .passenger {
                titleLabel.text = "En route to passenger"
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            } else {
                titleLabel.text = "Driver en route"
                buttonAction = .cancel
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
            infoViewLabel.text = String(otherUser.name.first ?? "X")
            uberInfoLabel.text = otherUser.name
            
        case .pickupPassenger:
            titleLabel.text = "Arrived at Passenger Location"
            buttonAction = .pickup
            actionButton.setTitle(buttonAction.description, for: .normal)
            
        case .tripInProgress:
            guard let otherUser = user else { return }
            
            if otherUser.accountType == .driver {
                actionButton.setTitle("TRIP IN PROGRESS", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
            titleLabel.text = "En Route to Destination"
            
        case .endTrip:
            guard let otherUser = user else { return }
            
            if otherUser.accountType == .driver {
                actionButton.setTitle("ARRIVED AT DESTINATION", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .dropoff
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
        }
    }
    
}
