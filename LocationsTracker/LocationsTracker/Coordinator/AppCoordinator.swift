//
//  AppCoordinator.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 15.02.2024.
//

import UIKit
import Combine

class AppCoordinator: BaseCoordinator {
    
    var authorizedManager = AuthorizedManager.shared
    private var cancellable = Set<AnyCancellable>()
    
    required init(_ navigationController: UINavigationController, type: CoordinatorType) {
        super.init(navigationController, type: type)
        start()
    }
    
    override func start() {
       // sinkToSessionState()
        showLoginFlow()
    }
    
    func sinkToSessionState() {
        authorizedManager.$sessionState
            .sink { [weak self] state in
            switch state {
            case .loggedIn:
                self?.coordinatorDidFinish(childCoordinator: .user)
            case .loggedOut:
                self?.coordinatorDidFinish(childCoordinator: .login)
            case .unknow:
                self?.coordinatorDidFinish(childCoordinator: .login)
            }
        }
        .store(in: &cancellable)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.authorizedManager.setupFirebaseAuth()
        }
    }
        
    func showLoginFlow() {
        let loginCoordinator = LoginCoordinator.init(navigationController, type: .login)
        loginCoordinator.finishDelegate = self
        loginCoordinator.appCoordinator = self
        loginCoordinator.start()
        childCoordinators.append(loginCoordinator)
    }
    
    func showMainFlow() {
       let userCoordinator = UserCoordinator.init(navigationController, type: .user)
        userCoordinator.finishDelegate = self
        userCoordinator.appCoordinator = self
        userCoordinator.start()
        childCoordinators.append(userCoordinator)
    }
}

extension AppCoordinator: CoordinatorFinishDelegate {
    
    func coordinatorDidFinish(childCoordinator: CoordinatorType) {
        childCoordinators = childCoordinators.filter({ $0.type != childCoordinator })
        
        switch childCoordinator {
        case .login:
            navigationController.viewControllers.removeAll()
            showLoginFlow()
            
        case .user:
            navigationController.viewControllers.removeAll()
            showMainFlow()
        }
    }
}

