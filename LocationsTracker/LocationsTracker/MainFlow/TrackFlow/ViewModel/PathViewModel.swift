//
//  PathViewModel.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 23.02.2024.
//
import Combine
import Foundation
import GoogleMaps
import CoreLocation

class PathViewModel {
    
    @Published var model: UserTrack {
        didSet {
            print("Changed")
        }
    }
    @Published var isReload = false
    @Published var error: Error?
    let path = GMSMutablePath()
    let dataBaseManager = DatabaseManager.shared
    
    init(model: UserTrack) {
        self.model = model
        addListenerIfNeeded()
    }
    
    func addListenerIfNeeded() {
        guard let isFinished = model.isFinish, !isFinished,
        let uidDoc = model.uidDocument
        else { return }
        
        dataBaseManager.addListenerForDocument(uidDoc) { [weak self] result in
            switch result {
            case .success(let userTrack):
                guard let userModel = userTrack else {return}
                self?.model = userModel
                self?.isReload = true
            case .failure(let error):
                self?.error = error
            }
        }
    }
    
    func createPathTrack() {
        path.removeAllCoordinates()
        guard let coordinates = model.trackCoordinates else { return }
        coordinates.forEach{addCoordinateToPath($0.coordinate)}
    }
    
    private func addCoordinateToPath(_ coordinate: CLLocationCoordinate2D) {
        path.add(coordinate)
    }
    
    deinit {
        print("Deinit PathViewModel")
        dataBaseManager.removeListener()
    }
    
}
