//
//  DatabaseManager.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 15.02.2024.
//
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCore
import Firebase
import FirebaseDatabase
import UIKit

final class DatabaseService {
    
    static let shared = DatabaseService()
    var userToSendEvent: UserProfile?
    private init() {}
    
    enum FirebaseRefferencies {
        case profile
        case errorInfo
        
        var ref: CollectionReference {
            switch self {
            case .profile:
                return Firestore.firestore().collection(Constants.profileCollection)
            case .errorInfo:
                return Firestore.firestore().collection(Constants.errorInfo)
            }
        }
    }
    
    ///Fetch users profile document from server FireStore
    func fetchProfile(uid: String, completion: @escaping (Result<UserProfile?,Error>)->Void) {
       
        Firestore.firestore().collection(Constants.profileCollection).document(uid).getDocument {document, error in
            
            if let document = document, document.exists {
                do {
                    let userProfile = try document.data(as: UserProfile.self)
                    completion(.success(userProfile))
                } catch {
                    completion(.failure(AuthorizeError.errorParceProfile))
                }
            } else {
                completion(.failure(AuthorizeError.docNotExists))
            }
        }
    }
    
    func deleteProfile(uid: String, errorHandler: ((Error?)->Void)? ) {
        FirebaseRefferencies.profile.ref.document(uid).delete { error in
            errorHandler?(error)
        }
    }
    
    func deleteProfileAsync() async {
        let uid = UserDefaults.standard.string(forKey: Constants.uid) ?? ""
        try? await FirebaseRefferencies.profile.ref.document(uid).delete()
    }
    
    func sendProfileToServer(uid: String, profile: UserProfile, errorHandler: ((Error?)->Void)?) {
        do {
            try FirebaseRefferencies.profile.ref.document(uid).setData(from: profile, merge: true)
        } catch {
            errorHandler?(AuthorizeError.sendDataFailed)
        }
    }
    
    @MainActor
    func uploadErrorToServer(error: Error) async throws {
        
        guard let uid = UserDefaults.standard.string(forKey: Constants.uid) else { throw AuthorizeError.uidUserFail }
        
        let errorString = error.localizedDescription
        let errorModel = ErrorModel(errorMessage: errorString, uidUser: uid)
        
        guard let errorData = try? Firestore.Encoder().encode(errorModel) else {
            throw AuthorizeError.errorEncode
        }
        
        let uidDoc = UUID().uuidString
        
        try await FirebaseRefferencies.errorInfo.ref.document(uidDoc).setData(errorData)
    }
    
    @MainActor
    func checkEmailIsExist(email: String) async throws -> Bool {
        let qSnapShot = try await FirebaseRefferencies.profile.ref.whereField("login", isEqualTo: email).getDocuments().documents
        
        for value in qSnapShot {
            guard let user = UserProfile(qSnapShot: value) else { return false }
            userToSendEvent = user
            return true
        }
        return false
    }
}

