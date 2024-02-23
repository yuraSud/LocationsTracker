//
//  UserProfile.swift
//  Movies
//
//  Created by Yura Sabadin on 06.01.2024.
//

import FirebaseFirestore
import Foundation

struct UserProfile: Codable {
    
    var login: String
    var uid: String
    var isManager: Bool
    var managerEmail: String?
    
    var firstLetter:  String  {
        login.first?.uppercased() ?? "?"
    }
    
    init(login: String, uid: String = "", isManager: Bool = false, emailManager: String? = nil) {
        self.login = login
        self.uid = uid
        self.isManager = isManager
        self.managerEmail = emailManager
    }
    
    init?(qSnapShot: QueryDocumentSnapshot) {
        let data = qSnapShot.data()
        let uid = data["uid"] as? String
        let login = data["login"] as? String
        let isMngr = data["isManager"] as? Bool
        let emailMngr = data["managerEmail"] as? String
        
        self.login = login ?? "None"
        self.uid = uid ?? ""
        self.isManager = isMngr ?? false
        self.managerEmail = emailMngr
    }
}
