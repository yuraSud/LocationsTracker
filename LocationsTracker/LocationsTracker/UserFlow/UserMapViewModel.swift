//
//  UserMapViewModel.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 16.02.2024.
//
import Combine
import CoreLocation
import Foundation

class UserMapViewModel {
    
    private var cancellables = Set<AnyCancellable>() {
        didSet {
            print(cancellables.count, "cancellables")
        }
    }
    
    @Published var currentCoordinates: CLLocation?
    
    var coordinatesForTrack = [CLLocation]()
    var arrayCoordinates = [CLLocation]() {
        didSet {
            print(arrayCoordinates.count)
        }
    }
    
    init() {
        
    }
    
    func startRecording() {
        coordinatesForTrack = []
        
        $currentCoordinates
            .throttle(for: .seconds(5), scheduler: DispatchQueue.main, latest: false)
            .compactMap{$0}
            .sink { [weak self] coordinates in
                guard let self else {return}
                arrayCoordinates.append(coordinates)
                coordinatesForTrack.append(coordinates)
                if arrayCoordinates.count > 100 {
                    uploadCoordinates()
                }
            }
            .store(in: &cancellables)
    }
    
    func stopRecording() {
        cancellables.removeAll()
        uploadCoordinates()
    }
    
    func uploadCoordinates() {
        let arrayForUpload = arrayCoordinates
        arrayCoordinates = []
        //TODO: - arrayForUpload upload to firebase
    }
}
