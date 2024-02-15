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
        
        let loginVC = LoginViewController()
        navigationController.pushViewController(loginVC, animated: true)
    }
}

