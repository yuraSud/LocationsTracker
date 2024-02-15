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
    
    init(login: String, uid: String = "", isManager: Bool = false) {
        self.login = login
        self.uid = uid
        self.isManager = isManager
    }
    
    init?(qSnapShot: QueryDocumentSnapshot) {
        let data = qSnapShot.data()
        let uid = data["uid"] as? String
        let login = data["login"] as? String
        let isMngr = data["isManager"] as? Bool
        
        self.login = login ?? "None"
        self.uid = uid ?? ""
        self.isManager = isMngr ?? false
    }
}
