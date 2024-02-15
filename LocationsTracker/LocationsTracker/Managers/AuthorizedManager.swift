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
    
    var uid = ""
    
    private var cancellables = Set<AnyCancellable>()
    private var handle: AuthStateDidChangeListenerHandle?
    
    func setupFirebaseAuth() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            self.sessionState = user == nil ? .loggedOut : .loggedIn
            guard let user = user else { return }
            self.uid = user.uid
            
            DatabaseService.shared.fetchProfile(uid: self.uid) { result in
                switch result {
                case .success(let userData):
                    self.userProfile = userData
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            UserDefaults.standard.set(user.uid, forKey: Constants.uid)
        }
    }
    
    func logIn(email: String, pasword: String, errorHandler: ((Error)->Void)?) {
        Auth.auth().signIn(withEmail: email, password: pasword) { result, error in
            if let err = error {
                errorHandler?(err)
                
            } else if result != nil {

                self.userDefaults.set(email, forKey: Constants.userEmail)
                self.userDefaults.set(pasword, forKey: Constants.userPassword)
            }
        }
    }
    
    func signUp(_ email: String, _ pasword: String, profile: UserProfile?, errorHandler: ((Error?)->Void)?) {
        guard var profile = profile else { return }
       
        Auth.auth().createUser(withEmail: email, password: pasword) { [weak self] result, error in
            if let error = error {
                errorHandler?(error)
            } else {
                guard let user = result?.user else {
                    errorHandler?(AuthorizeError.userNotFound)
                    return}
            
                let uid = user.uid
                self?.uid = uid
                profile.uid = uid

                self?.userDefaults.set(email, forKey: Constants.userEmail)
                self?.userDefaults.set(pasword, forKey: Constants.userPassword)
                
                DatabaseService.shared.sendProfileToServer(uid: uid, profile: profile) { error in
                    errorHandler?(error)
                }
            }
        }
    }
    
    func deleteUser(errorHandler: ((Error?)->Void)?) {
        guard let user = Auth.auth().currentUser else {
            errorHandler?(AuthorizeError.userNotFound)
            return
        }
        self.userDefaults.set(nil, forKey: Constants.userEmail)
        self.userDefaults.set(nil, forKey: Constants.userPassword)
       
        DatabaseService.shared.deleteProfile(uid: user.uid) { errorHandler?($0) }
        user.delete { errorHandler?($0) }
        logOut()
    }
    
    func logOut() {
        try? Auth.auth().signOut()
        self.uid = ""
        self.userProfile = nil
    }
}

