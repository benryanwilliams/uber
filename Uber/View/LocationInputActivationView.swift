//
//  LocationInputActivationView.swift
//  Uber
//
//  Created by Ben Williams on 13/01/2021.
//

import UIKit

protocol LocationInputActivationViewDelegate: AnyObject {
    func presentLocationInputView()
}

class LocationInputActivationView: UIView {
    
    public weak var delegate: LocationInputActivationViewDelegate?
    
    // MARK:- Properties
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let placeholderLabel: UILabel = {
       let label = UILabel()
        label.text = "Where to?"
        label.font = .systemFont(ofSize: 18)
        label.textColor = .darkGray
        return label
    }()
    
    
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        
        // When tapped, present input activation view
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInputActivationView))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Helper Functions
    
    private func configureUI() {
        backgroundColor = .white
        
        addShadow()
        layer.masksToBounds = false
        
        addSubview(indicatorView)
        indicatorView.centerY(inView: self, leftAnchor: self.leftAnchor, paddingLeft: 16)
        indicatorView.setDimensions(height: 6, width: 6)
        
        addSubview(placeholderLabel)
        placeholderLabel.centerY(inView: self, leftAnchor: indicatorView.rightAnchor, paddingLeft: 20)
        
    }
    
    @objc func didTapInputActivationView() {
        delegate?.presentLocationInputView()
    }
}
