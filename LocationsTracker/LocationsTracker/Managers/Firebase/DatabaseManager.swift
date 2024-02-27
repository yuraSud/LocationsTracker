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

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    private var listenerDocument: ListenerRegistration? = nil
    private init() {}
    
    enum FirebaseRefferencies {
        case profile
        case userTrack
        case errorInfo
        
        var ref: CollectionReference {
            switch self {
            case .profile:
                return Firestore.firestore().collection(Constants.profileCollection)
            case .userTrack:
                return Firestore.firestore().collection(Constants.userTrack)
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
        
    func uploadTrackToServer(uidTrack: String, trackModel: UserTrack) async throws {
        guard let trackData = try? Firestore.Encoder().encode(trackModel) else {
            throw AuthorizeError.trackEncode
        }
        try await FirebaseRefferencies.userTrack.ref.document(uidTrack).setData(trackData, merge: true)
    }
    
    func deleteDocument(_ uidDocoment: String) async throws {
        try await FirebaseRefferencies.userTrack.ref.document(uidDocoment).delete()
    }
    
    func sendProfileToServer(uid: String, profile: UserProfile) async throws {
        guard let profileData = try? Firestore.Encoder().encode(profile) else {
            throw AuthorizeError.profileEncode
        }
        try await FirebaseRefferencies.profile.ref.document(uid).setData(profileData, merge: true)
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
        let qSnapShot = try await FirebaseRefferencies.profile.ref.whereField(Constants.login, isEqualTo: email).getDocuments().documents
        let users = qSnapShot.compactMap({ try? $0.data(as: UserProfile.self) })
        let result = users.filter({$0.isManager})
        return !result.isEmpty
    }
    
    @MainActor
    func getUserTracks(uid: String) async throws -> [UserTrack] {
        let qSnapShot = try await FirebaseRefferencies.userTrack.ref.whereField(Constants.uidUser, isEqualTo: uid).getDocuments().documents
        let userTracks = qSnapShot.compactMap({ try? $0.data(as: UserTrack.self) })
        return userTracks
    }
    
    @MainActor
    func getManagerAllUsersTracks(managerEmail: String) async throws -> [UserTrack] {
        let qSnapShot = try await FirebaseRefferencies.userTrack.ref.whereField(Constants.managerEmail, isEqualTo: managerEmail).getDocuments().documents
        let usersTracks = qSnapShot.compactMap({ try? $0.data(as: UserTrack.self) })
        return usersTracks
    }
    
    func addListenerForDocument(_ uidDocument: String, completion: ((Result<UserTrack?, Error>)->Void)?) {
        
        let documentReference = FirebaseRefferencies.userTrack.ref.document(uidDocument)

        listenerDocument = documentReference.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                completion?(.failure(AuthorizeError.errorGetDocument))
                return
            }
            
            if document.exists {
                let userTrack = try? document.data(as: UserTrack.self)
                completion?(.success(userTrack))
            } else {
                completion?(.failure(AuthorizeError.documentIsNotExists))
            }
        }
    }
    
    func removeListener() {
        listenerDocument?.remove()
        listenerDocument = nil
    }
    
}

