//
//  MapUserCoordinator.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 15.02.2024.
//

import Foundation

class UserCoordinator: BaseCoordinator {

    weak var appCoordinator: AppCoordinator?
    
    override func start() {
        showUserViewController()
    }
    
    func showUserViewController() {
        let userVC = UserViewController()
        
        
        navigationController.pushViewController(userVC, animated: true)
    }
}
