//
//  SignUpViewController.swift
//  Uber
//
//  Created by Ben Williams on 07/01/2021.
//

import UIKit

class SignUpViewController: UIViewController {

    // MARK:- Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
        view.anchor(height: 50)
        return view
    }()
    
    private lazy var nameContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: nameTextField)
        view.anchor(height: 50)
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
        view.anchor(height: 50)
        return view
    }()
    
    private lazy var accountTypeContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_account_box_white_2x"), segmentedControl: accountTypeSegmentedControl)
        view.anchor(height: 80)
        return view
    }()
    
    private let emailTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    private let nameTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Full Name", isSecureTextEntry: false)
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
    
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Rider", "Driver"])
        sc.backgroundColor = UIColor.black
        sc.layer.borderColor = UIColor(white: 1, alpha: 0.87).cgColor
        sc.layer.borderWidth = 1
        sc.selectedSegmentTintColor = UIColor(white: 1, alpha: 0.87)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.backgroundColor], for: .selected)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let signUpButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = UIButton()
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Log In", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.mainBlueTint]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(didTapAlreadyHaveAccountButton), for: .touchUpInside)
        
        return button
    }()
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        view.backgroundColor = .backgroundColor

      
    }
    
    // MARK:- Actions
    
    @objc func didTapAlreadyHaveAccountButton() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK:- Helpers
    
    private func configureUI() {
        view.backgroundColor = .backgroundColor
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        titleLabel.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, nameContainerView, passwordContainerView, accountTypeContainerView, signUpButton])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 24
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor,
                     left: view.leftAnchor,
                     right: view.rightAnchor,
                     paddingTop: 40,
                     paddingLeft: 16,
                     paddingRight: 16)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(bottom: view.bottomAnchor)
        alreadyHaveAccountButton.centerX(inView: view)
        
    }

}
