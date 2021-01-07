//
//  AuthButton.swift
//  Uber
//
//  Created by Ben Williams on 07/01/2021.
//

import UIKit

class AuthButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitle("Log in", for: .normal)
        setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        backgroundColor = .mainBlueTint
        clipsToBounds = true
        layer.cornerRadius = 5
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
