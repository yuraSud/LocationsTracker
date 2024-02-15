//
//  SignUpViewController.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 15.02.2024.
//

import UIKit
import Combine


class SignUpViewController: UIViewController {
    
    var didSendEventClosure: ((Event) -> Void)?
    
    private let titleLabel = UILabel()
    private let signUpLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let emailNumberTextField = UITextFieldPadding()
    private let passwordTextField = UITextFieldPadding()
    private let managerEmailTextField = UITextFieldPadding()
    private let logInButton = UIButton(type: .system)
    private let signUpButton = UIButton(type: .system)
    private var titlesStack = UIStackView()
    private var authorizedStack = UIStackView()
    private var signUpStack = UIStackView()
    private let keychainManager = KeychainManager.shared
    private var email = ""
    private var password = ""
    private let vm: LoginViewModel
    private var cancellable = Set<AnyCancellable>()
    private var isManager = false {
        didSet { managerEmailTextField.isHidden = isManager }
    }
    
    
    init(viewModel: LoginViewModel ) {
        self.vm = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setSignInButton()
        setTitlesLabel()
        setTitlesStack()
        setAuthorisedTextFields()
        setAuthorizedStack()
        setSignInStack()
        setAuthorisedButton()
        setConstraint()
        sinkToProperties()
    }
    
    //MARK: - @objc Function
    
    @objc func signUpUser() {
        guard let email = emailNumberTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else { return }
        keychainManager.save(password: password, account: email)
        
        let user = UserProfile(login: email)
        
        vm.signUp(email, password, profile: user)
    }
    
    @objc func goToLogIn() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - private Function
    
    private func sinkToProperties() {
        emailNumberTextField.$userType.sink { [weak self] type in
            self?.isManager = type == .manager
        }
        .store(in: &cancellable)
        
        vm.$error
            .compactMap{$0}
            .sink { [weak self] error in
                self?.presentAlert(with: "Error", message: error.localizedDescription, buttonTitles: "Ok", styleActionArray: [.cancel], alertStyle: .alert, completion: nil)
            }
            .store(in: &cancellable)
    }
}

//MARK: - TextFieldDelegate

extension SignUpViewController: UITextFieldDelegate {
    
    private func minimizePlaceholder(_ tf: UITextField) {
        UIView.animate(withDuration: 0.3) {
            guard let tf = tf as? UITextFieldPadding else { return }
            tf.configureFrameCustomPlaceHolder(frame: .init(x: 14, y: 3, width: 200, height: 17))
        }
    }
    
    private func expandLabel(_ tf: UITextField) {
        UIView.animate(withDuration: 0.5) {
            guard let tf = tf as? UITextFieldPadding else { return }
            tf.configureFrameCustomPlaceHolder(frame: .init(x: 14, y: 5, width: 200, height: 40))
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailNumberTextField {
            minimizePlaceholder(textField)
        } else {
            minimizePlaceholder(textField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, text.isEmpty else { return }
        if textField == emailNumberTextField {
            expandLabel(textField)
        } else {
            expandLabel(textField)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailNumberTextField {
            passwordTextField.becomeFirstResponder()
        } else  if textField == passwordTextField && !isManager {
            managerEmailTextField.becomeFirstResponder()
        } else {
            textField.endEditing(true)
        }
        return true
    }
}

//MARK: - setView elements:

extension SignUpViewController {
    
    private func setupView() {
        view.backgroundColor = .black
        let background = UIImageView()
        background.frame = view.bounds
        background.image = ImageConstants.signUpBackground
        background.contentMode = .scaleAspectFill
        background.alpha = 0.5
        view.addSubview(background)
    }
    
    private func setTitlesLabel() {
        let labels = [titleLabel, descriptionLabel]
        labels.forEach { label in
            label.textAlignment = .left
            label.numberOfLines = 0
            label.textColor = .white
        }
        titleLabel.text = Constants.welcomeApp
        titleLabel.font = .systemFont(ofSize: 40, weight: .bold)
        descriptionLabel.text = Constants.signUpDescription
        descriptionLabel.font = .systemFont(ofSize: 22)
    }
    
    private func setTitlesStack() {
        titlesStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        titlesStack.axis = .vertical
        titlesStack.spacing = 10
        titlesStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titlesStack)
    }
    
    private func setAuthorisedTextFields() {
        let textFields = [emailNumberTextField, passwordTextField, managerEmailTextField]
        let placeholderArray = [Constants.email, Constants.password, Constants.manager]
        
        textFields.enumerated().forEach { index, tf in
            tf.delegate = self
            tf.font = .systemFont(ofSize: 19)
            tf.configureCustomPlaceholder(text: placeholderArray[index],
                                          frame: .init(x: 14, y: 5, width: 200, height: 40))
            
            tf.setBorderLayer(backgroundColor: .secondarySystemBackground,
                              borderColor: .lightGray,
                              borderWidth: 1,
                              cornerRadius: 9,
                              tintColor: nil)
        }
        passwordTextField.addSequreAndClearButtons()
        emailNumberTextField.setRightButtonOnTextField()
        managerEmailTextField.setActivityIndicator()
        managerEmailTextField.addEmailImageAndClearButton()
        passwordTextField.accessibilityIdentifier = "PasswordTF"
        emailNumberTextField.accessibilityIdentifier = "LoginTF"
        managerEmailTextField.accessibilityIdentifier = "managerTF"
    }
    
    private func setAuthorizedStack() {
        authorizedStack = UIStackView(arrangedSubviews: [emailNumberTextField,passwordTextField, managerEmailTextField])
        authorizedStack.axis = .vertical
        authorizedStack.spacing = 20
        authorizedStack.distribution = .fillEqually
        authorizedStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(authorizedStack)
    }
    
    private func setSignInButton() {
        logInButton.setTitle(Constants.signUpButton, for: .normal)
        logInButton.addTarget(self, action: #selector(signUpUser), for: .touchUpInside)
        signUpButton.setTitle(Constants.logInButton, for: .normal)
        signUpLabel.text = Constants.signUpLabel
    }
    
    private func setAuthorisedButton() {
        logInButton.translatesAutoresizingMaskIntoConstraints = false
        logInButton.backgroundColor = ColorConstans.logInColor
        logInButton.tintColor = .label
        logInButton.layer.cornerRadius = 10
        logInButton.layer.borderColor = UIColor.gray.cgColor
        logInButton.layer.borderWidth = 1
        logInButton.titleLabel?.font = .systemFont(ofSize: 18)
        view.addSubview(logInButton)
    }
    
    private func setSignInStack() {
        signUpLabel.textColor = .white
        signUpLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        signUpButton.tintColor = ColorConstans.logInColor
        signUpButton.addTarget(self, action: #selector(goToLogIn), for: .touchUpInside)
        signUpButton.titleLabel?.font = .systemFont(ofSize: 20)
        
        signUpStack = UIStackView(arrangedSubviews: [signUpLabel, signUpButton])
        signUpStack.axis = .horizontal
        signUpStack.spacing = 15
        signUpStack.translatesAutoresizingMaskIntoConstraints = false
        signUpStack.alignment = .center
        view.addSubview(signUpStack)
    }
}

//MARK: - constraints:
extension SignUpViewController {
    
    private func setConstraint() {
        NSLayoutConstraint.activate([
            
            titlesStack.topAnchor.constraint(equalTo: navigationItem.titleView?.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titlesStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titlesStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            authorizedStack.topAnchor.constraint(equalTo: titlesStack.bottomAnchor, constant: 50),
            authorizedStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            authorizedStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
           
            logInButton.topAnchor.constraint(equalTo: authorizedStack.bottomAnchor, constant: 50),
            logInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logInButton.heightAnchor.constraint(equalToConstant: 45),
            
            signUpStack.heightAnchor.constraint(equalToConstant: 50),
            signUpStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            signUpStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            signUpStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}
