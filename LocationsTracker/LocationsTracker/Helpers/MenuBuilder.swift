//
//  MenuBuilder.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 15.02.2024.
//

import UIKit

enum UserType {
    case user, manager
    
    var title: String {
        switch self {
        case .user: return "User"
        case .manager: return "Manager"
        }
    }
}

final class MenuBuilder {
    
    var userType: UserType = .user
    var userTypeButton: UIButton = UIButton()
    var completionTypeUser: ((UserType)->Void)?
    
    init(_ userType: UserType, _ userTypeButton: UIButton) {
        self.userType = userType
        self.userTypeButton = userTypeButton
    }
    
    func typeUserMenu(typePicture: String? = nil) -> UIMenu {
        
        let user = UIAction(title: UserType.user.title, image: ImageConstants.userImage, attributes: .keepsMenuPresented) { action in
            self.userType = .user
            self.userTypeButton.menu = self.typeUserMenu(typePicture: action.title)
        }
        let manager = UIAction(title: UserType.manager.title, image: ImageConstants.managerImage) { action in
            self.userType = .manager
            self.userTypeButton.menu = self.typeUserMenu(typePicture: action.title)
        }
        
        let menu = UIMenu(title: Constants.userType, image: nil, options: .singleSelection, children: [user, manager])
        
        if let typePicture = typePicture {
            menu.children.forEach { action in
                guard let action = action as? UIAction else {return}
                if action.title == typePicture {
                    action.state = .on
                    action.attributes = .destructive
                }
            }
        } else {
            let action = menu.children.first as? UIAction
            action?.state = .on
        }
        completionTypeUser?(userType)
        return menu
    }
}


