//
//  SignUpViewController.swift
//  Uber
//
//  Created by Ben Williams on 07/01/2021.
//

import UIKit
import Firebase

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
        let textField = UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
        return textField
    }()
    
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Rider", "Driver"])
        sc.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        sc.tintColor = UIColor(white: 1, alpha: 0.87)
        sc.layer.borderColor = UIColor(white: 1, alpha: 0.87).cgColor
        sc.layer.borderWidth = 1
        sc.selectedSegmentTintColor = UIColor(white: 1, alpha: 0.87)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.backgroundColor], for: .selected)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor(white: 1, alpha: 0.87)], for: .normal)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let signUpButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
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
    
    @objc func didTapSignUpButton() {
        guard let email = emailTextField.text else { return}
        guard let password = passwordTextField.text else { return }
        guard let name = nameTextField.text else { return }
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG: Failed to register user with error: \(error)")
                return
            }
            else {
                
                guard let uid = result?.user.uid else { return }
                
                let values = ["email": email, "password": password, "name": name, "accountType": accountTypeIndex] as [String : Any]
                
                Database.database().reference().child("users").child(uid).updateChildValues(values) { (error, ref) in
                    print("Successfully registered user and saved data")
                    
                    // Configure HomeViewController UI then return to it
                    guard let rootVC = UIApplication.shared.windows.first(where: \.isKeyWindow)?.rootViewController as? HomeViewController else { return }
                    rootVC.configureUI()
                    self.dismiss(animated: true, completion: nil)                }
            }
        }
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
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        alreadyHaveAccountButton.centerX(inView: view)
        
    }

}
