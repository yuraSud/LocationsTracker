//
//  LoginViewModel.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 15.02.2024.
//

import Foundation
import Combine

class LoginViewModel {
    
    @Published var error: Error?
    
    var authorizedManager = AuthorizedManager.shared
    
    func signUp(_ email: String, _ password: String, profile: UserProfile?) {
        Task {
            do {
                try await authorizedManager.signUp(email, password, profile: profile)
            } catch {
                self.error = error
            }
        }
    }
    
    func logIn(_ email: String, _ password: String) {
        Task {
            do {
                try await authorizedManager.logIn(email: email, pasword: password)
            } catch {
                self.error = error
            }
        }
    }
}
