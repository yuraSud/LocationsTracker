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
    
    init(login: String, uid: String = "") {
        self.login = login
        self.uid = uid
    }
    
    init?(qSnapShot: QueryDocumentSnapshot) {
        let data = qSnapShot.data()
        let uid = data["uid"] as? String
        let login = data["login"] as? String
        
        self.login = login ?? "Nothin"
        self.uid = uid ?? "uid"
    }
}
