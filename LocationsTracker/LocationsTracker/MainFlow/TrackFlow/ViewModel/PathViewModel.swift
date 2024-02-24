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
    
    let model: UserTrack
    let path = GMSMutablePath()
    
    init(model: UserTrack) {
        self.model = model
    }
    
    func createPathIfTrackFinished() {
        guard let coordinates = model.trackCoordinates else { return }
        coordinates.forEach{addCoordinateToPath($0.coordinate)}
    }
    
    private func addCoordinateToPath(_ coordinate: CLLocationCoordinate2D) {
        path.add(coordinate)
    }
    
}
