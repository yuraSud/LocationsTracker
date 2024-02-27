//
//  AuthorizedManager.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 15.02.2024.

import Foundation
import FirebaseCore
import Combine
import FirebaseAuth

enum SessionState {
    case loggedIn
    case loggedOut
    case unknow
}

final class AuthorizedManager: NSObject {
    
    static let shared = AuthorizedManager()
    private let userDefaults = UserDefaults.standard
    
    @Published var userProfile: UserProfile?
    @Published var sessionState: SessionState = .unknow
    @Published var error: Error?
    
    var uid = ""
    private let databaseService = DatabaseManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var handle: AuthStateDidChangeListenerHandle?
    
    func setupFirebaseAuth() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            self.sessionState = user == nil ? .loggedOut : .loggedIn
            guard let user = user else { return }
            self.uid = user.uid
            
            DatabaseManager.shared.fetchProfile(uid: self.uid) { result in
                switch result {
                case .success(let userData):
                    self.userProfile = userData
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            userDefaults.set(user.uid, forKey: Constants.uid)
        }
    }
    
    func getUserDocuments() {
        databaseService.fetchProfile(uid: self.uid) { result in
            switch result {
            case .success(let userProfile):
                self.userProfile = userProfile
            case .failure(let error):
                self.error = error
                self.userProfile = nil
            }
        }
    }

    func logIn(email: String, pasword: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: pasword)
       
        self.userDefaults.set(email, forKey: Constants.userEmail)
    }
        
    func signUp(_ email: String, _ password: String, profile: UserProfile?) async throws {
        guard var profileUser = profile else { return }
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid
        
        profileUser.uid = uid
        
        self.userDefaults.set(email, forKey: Constants.userEmail)
        self.userDefaults.set(uid, forKey: Constants.uid)
        
        try await DatabaseManager.shared.sendProfileToServer(uid: uid, profile: profileUser)
    }
    
    func deleteUser(errorHandler: ((Error?)->Void)?) {
        guard let user = Auth.auth().currentUser else {
            errorHandler?(AuthorizeError.userNotFound)
            return
        }
        self.userDefaults.set(nil, forKey: Constants.userEmail)
       
        DatabaseManager.shared.deleteProfile(uid: user.uid) { errorHandler?($0) }
        user.delete { errorHandler?($0) }
        logOut()
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        self.uid = ""
        self.userProfile = nil
    }
}

