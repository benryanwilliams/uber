//
//  LocationInputView.swift
//  Uber
//
//  Created by Ben Williams on 14/01/2021.
//

import UIKit

protocol LocationInputViewDelegate: AnyObject {
    func dismissLocationInputView()
}

class LocationInputView: UIView {
    
    weak var delegate: LocationInputViewDelegate?
    
    // MARK:- Properties
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.text = "Ben Williams"
        label.textColor = .darkGray
        return label
    }()
    
    private let startingLocationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Current Location"
        textField.backgroundColor = .systemGroupedBackground
        textField.font = .systemFont(ofSize: 16)
        textField.isUserInteractionEnabled = false
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let destinationLocationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter a destination"
        textField.backgroundColor = .lightGray
        textField.font = .systemFont(ofSize: 16)
        textField.returnKeyType = .search
        
        let leftView = UIView()
        leftView.setDimensions(height: 30, width: 8)
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let startLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let linkingView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let destinationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addShadow()
        
        configureBackButton()
        
        addSubview(titleLabel)
        titleLabel.centerX(inView: self)
        titleLabel.centerY(inView: backButton)
        
        addSubview(startingLocationTextField)
        startingLocationTextField.anchor(top: backButton.bottomAnchor, left: leftAnchor,
                                         right: rightAnchor, paddingTop: 8, paddingLeft: 40,
                                         paddingRight: 40, height: 30)
        
        addSubview(destinationLocationTextField)
        destinationLocationTextField.anchor(top: startingLocationTextField.bottomAnchor, left: leftAnchor,
                                         right: rightAnchor, paddingTop: 20, paddingLeft: 40,
                                         paddingRight: 40, height: 30)
        
        addSubview(startLocationIndicatorView)
        startLocationIndicatorView.centerY(inView: startingLocationTextField)
        startLocationIndicatorView.centerX(inView: backButton)
        startLocationIndicatorView.setDimensions(height: 6, width: 6)
        startLocationIndicatorView.layer.cornerRadius = 6/2
        
        addSubview(destinationIndicatorView)
        destinationIndicatorView.centerY(inView: destinationLocationTextField)
        destinationIndicatorView.centerX(inView: backButton)
        destinationIndicatorView.setDimensions(height: 6, width: 6)
        
        addSubview(linkingView)
        linkingView.centerX(inView: startLocationIndicatorView)
        linkingView.anchor(top: startLocationIndicatorView.bottomAnchor, bottom: destinationIndicatorView.topAnchor, paddingTop: 4, paddingBottom: 4, width: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Actions
    
    @objc func didTapBackButton() {
        print("Back button tapped")
        delegate?.dismissLocationInputView()
        
    }
    
    // MARK:- Helper Functions
    
    private func configureBackButton() {
        addSubview(backButton)
        backButton.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, paddingTop: 20,
                          paddingLeft: 12, width: 24, height: 25)
    }
    
    
    
}
