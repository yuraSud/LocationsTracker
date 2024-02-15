//
//  BaseCoordinator.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 15.02.2024.


import UIKit

class BaseCoordinator: NSObject, CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType
    
    func start() {}
    
    required init(_ navigationController: UINavigationController, type: CoordinatorType) {
        self.navigationController = navigationController
        self.navigationController.setNavigationBarHidden(true, animated: true)
        self.type = type
    }
}
