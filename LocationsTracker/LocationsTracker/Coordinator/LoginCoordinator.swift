//
//  LoginCoordinator.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 15.02.2024.
//

import UIKit


class LoginCoordinator: BaseCoordinator {
    
    weak var appCoordinator: AppCoordinator?
   
    override func start() {
        showLoginViewController()
    }
    
    func showLoginViewController() {
        let loginVC: LoginViewController = .init()
//        loginVC.didSendEventClosure = { [weak self] event in
//            
//            switch event {
//                
//            case .logIn(let email, let password):
//                self?.appCoordinator?.authorizedManager.logIn(email: email, pasword: password, errorHandler: { [weak loginVC] error in
//                    loginVC?.presentAlert(with: "Error", message: error.localizedDescription, buttonTitles: "Ok", styleActionArray: [.cancel], alertStyle: .alert, completion: nil)
//                })
//                
//            case .signUp(let email, let password):
//                let user = UserProfile(login: email)
//                self?.appCoordinator?.authorizedManager.signUp(email, password, profile: user, errorHandler: { [weak loginVC] error in
//                    loginVC?.presentAlert(with: "Error", message: error?.localizedDescription, buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
//                })
//            }
//        }
        navigationController.pushViewController(loginVC, animated: true)
    }
}

