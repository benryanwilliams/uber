//
//  Extensions.swift
//  Uber
//
//  Created by Ben Williams on 06/01/2021.
//

import UIKit

// MARK:- UIColor

extension UIColor {
    
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
            return UIGraphicsImageRenderer(size: size).image { rendererContext in
                self.setFill()
                rendererContext.fill(CGRect(origin: .zero, size: size))
            }
        }
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    
    static let backgroundColor = rgb(red: 25, green: 25, blue: 25)
    static let mainBlueTint = rgb(red: 17, green: 154, blue: 237)
}

// MARK:- UIView

extension UIView {
    
    func inputContainerView(image: UIImage, textField: UITextField? = nil, segmentedControl: UISegmentedControl? = nil) -> UIView {
        let view = UIView()
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.alpha = 0.87
        view.addSubview(imageView)
        
        
        if let textField = textField {
            imageView.anchor(left: view.leftAnchor, paddingLeft: 8, width: 24, height: 24)
            imageView.centerY(inView: view)
            
            view.addSubview(textField)
            textField.centerY(inView: view)
            textField.anchor(left: imageView.rightAnchor,
                             bottom: view.bottomAnchor,
                             right: view.rightAnchor,
                             paddingLeft: 8)
        }
        
        if let sc = segmentedControl {
            imageView.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: -8, paddingLeft: 8, width: 24, height: 24)
            
            view.addSubview(sc)
            sc.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 8, paddingRight: 8)
            sc.centerY(inView: view, constant: 8)
        }
        
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        view.addSubview(separatorView)
        separatorView.anchor(left: view.leftAnchor,
                             bottom: view.bottomAnchor,
                             right: view.rightAnchor,
                             paddingLeft: 8,
                             paddingRight: 8,
                             height: 0.75)
        
        return view
    }
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
    }
    
    func centerX(inView view: UIView, constant: CGFloat = 0) {
        centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: constant).isActive = true
    }
    
    func centerY(inView view: UIView, constant: CGFloat = 0) {
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
    }
}

// MARK:- UITextField

extension UITextField {
    
    func textField(withPlaceholder placeholder: String, isSecureTextEntry: Bool) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .white
        textField.keyboardAppearance = .dark
        textField.isSecureTextEntry = isSecureTextEntry
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        )
        return textField
    }
}
