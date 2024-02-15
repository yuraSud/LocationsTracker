//
//  LoginViewModel.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 15.02.2024.
//

import Foundation
import Combine

@MainActor
class LoginViewModel {
    
    @Published var error: Error?
    @Published var email: String = ""
    @Published var managerIsExist = false
    private var authorizedManager = AuthorizedManager.shared
    private let fireStore = DatabaseManager.shared
    private var cancellable = Set<AnyCancellable>()
    
    
    init() {
        checkMailIsBusy()
    }
    
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
    
    func checkMailIsBusy() {
        $email
            .debounce(for: 0.8, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter{!$0.isEmpty && $0.contains("@") && $0.contains(".")}
            .sink { [weak self] email in
                guard let self else { return }
                Task {
                    do { self.managerIsExist = try await self.fireStore.checkEmailIsExist(email: email)
                        
                    } catch {
                        self.error = error
                    }
                }
            }
            .store(in: &cancellable)
    }
}
