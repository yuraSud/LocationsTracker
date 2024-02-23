//
//  SettingsViewController.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 22.02.2024.
//

import UIKit
import Combine

class SettingsViewController: UIViewController {
    
    private let usersImageLabel = UILabel()
    private let emailUserLabel = UILabel()
    private let deletProfileButton = UIButton(type: .system)
    private let logOutProfileButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let authService = AuthorizedManager.shared
    private var stackButtons = UIStackView()
    private var labelStack = UIStackView()
    private var user: UserProfile?
    private var subscribers = Set<AnyCancellable>()
    
    //MARK: - Life cycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setStackButtons()
        configLabelsStack()
        setCloseButton()
        setConstraints()
        addTargetButton()
        fetchCurrentUser()
        updateUser()
    }
    
    //MARK: - open Fuctions:
    
    func updateUser() {
        authService.$userProfile
            .receive(on: DispatchQueue.main)
            .filter{ $0 != nil }
            .sink { profile in
                self.user = profile
                self.setLabelsText()
            }.store(in: &subscribers)
        
        authService.$error
            .filter { $0 != nil }
            .sink { error in
                self.alertError(error)
            }.store(in: &subscribers)
    }
    
    func fetchCurrentUser() {
        authService.getUserDocuments()
        setLabelsText()
    }
    
    func setLabelsText() {
        guard let user else { return }
        emailUserLabel.text = "email: \(user.login)"
        usersImageLabel.text = user.firstLetter
    }
    
    //MARK: - @objc Functions:
    
    @objc private func closeVC() {
        self.dismiss(animated: true)
    }
    
    @objc private func logOut() {
        self.authService.logOut()
        closeVC()
    }
    
    @objc private func deleteUser() {
        defer {
            closeVC()
        }
        self.authService.deleteUser() { error in
            guard let error else {return}
            self.alertError(error)
        }
    }
    
    //MARK: - private Functions:
    
    private func setCloseButton() {
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        cancelButton.setImage(ImageConstants.clear, for: .normal)
        cancelButton.setBorderLayer(backgroundColor: .black, borderColor: .gray, borderWidth: 2, cornerRadius: 15, tintColor: .white)
    }
    
    private func configLabelsStack() {
        usersImageLabel.sizeToFit()
        usersImageLabel.layer.cornerRadius = 40
        usersImageLabel.font = .boldSystemFont(ofSize: 45)
        usersImageLabel.tintColor = .white
        usersImageLabel.backgroundColor = .systemMint
        usersImageLabel.textAlignment = .center
        usersImageLabel.clipsToBounds = true
        
        emailUserLabel.font = .systemFont(ofSize: 18)
        emailUserLabel.textAlignment = .left
        emailUserLabel.adjustsFontSizeToFitWidth = true
        
        labelStack = UIStackView(arrangedSubviews: [usersImageLabel,emailUserLabel])
        labelStack.axis = .horizontal
        labelStack.spacing = 30
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelStack)
    }
    
    private func setStackButtons() {
        let buttons = [logOutProfileButton, deletProfileButton]
        let titleArr = ["Log Out", "Delete profile"]
        buttons.enumerated().forEach { index, button in
            button.setTitle(titleArr[index], for: .normal)
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.setBorderLayer(backgroundColor: .link, borderColor: .gray, borderWidth: 2, cornerRadius: 20, tintColor: .white)
            button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        }
        stackButtons = UIStackView(arrangedSubviews: buttons)
        stackButtons.axis = .vertical
        stackButtons.spacing = 18
        stackButtons.distribution = .fillEqually
        stackButtons.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackButtons)
    }
    
    private func addTargetButton() {
        logOutProfileButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        deletProfileButton.addTarget(self, action: #selector(deleteUser), for: .touchUpInside)
    }
    
    //MARK: - constraints:
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            
            labelStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            labelStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            labelStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            labelStack.heightAnchor.constraint(equalToConstant: 80),
            
            stackButtons.topAnchor.constraint(equalTo: labelStack.bottomAnchor, constant: 60),
            stackButtons.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackButtons.widthAnchor.constraint(equalTo: labelStack.widthAnchor),
            
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            cancelButton.heightAnchor.constraint(equalTo: cancelButton.widthAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 30),
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            
            usersImageLabel.widthAnchor.constraint(equalTo: usersImageLabel.heightAnchor)
        ])
    }
    
}
