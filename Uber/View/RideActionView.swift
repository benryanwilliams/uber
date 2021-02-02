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
    
    private lazy var rideTypeXView: UIView = {
       let view = UIView()
        view.backgroundColor = .black
        
        let label = UILabel()
        label.text = "X"
        label.font = .systemFont(ofSize: 30)
        label.textColor = .white
        
        view.addSubview(label)
        label.centerX(inView: view)
        label.centerY(inView: view)
        
        return view
    }()
    
    private let uberXLabel: UILabel = {
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
        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
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
        
        addSubview(rideTypeXView)
        let size: CGFloat = 60
        rideTypeXView.anchor(top: stack.bottomAnchor, paddingTop: 16, width: size, height: size)
        rideTypeXView.centerX(inView: self)
        rideTypeXView.layer.cornerRadius = size/2
        
        addSubview(uberXLabel)
        uberXLabel.anchor(top: rideTypeXView.bottomAnchor, left: leftAnchor, right: rightAnchor)
        
        addSubview(separatorLine)
        separatorLine.anchor(top: uberXLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8, height: 0.75)
        
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
    
    @objc private func didTapConfirmButton() {
        delegate?.uploadTrip(self)
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
            
        case .pickupPassenger:
            break
        case .tripInProgress:
            break
        case .endTrip:
            break
        }
    }
    
}
