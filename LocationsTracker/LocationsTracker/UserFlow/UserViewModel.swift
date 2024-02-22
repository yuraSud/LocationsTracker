//
//  UserMapViewModel.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 16.02.2024.
//
import Combine
import CoreLocation
import Foundation
import GoogleMaps

class UserViewModel {
    
    @Published var currentCoordinates: CLLocation?
    @Published var trackCoordinates = [CLLocation]()
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    private var countCoordinates = 0
    private var timer: Timer?
    private var seconds = 0
    private var dateStart: Date?
    
    var trackInfo = TrackInfoModel()
    let path = GMSMutablePath()
    var uidUserTrack: String = ""
    
    init() {
        
    }
    
    func startRecording() {
        trackCoordinates = []
        countCoordinates = 0
        timer?.invalidate()
        path.removeAllCoordinates()
        dateStart = .now
        uidUserTrack = UUID().uuidString
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        $currentCoordinates
            .throttle(for: .seconds(5), scheduler: DispatchQueue.main, latest: true)
            .compactMap{$0}
            .sink { [weak self] coordinates in
                guard let self else {return}
                countCoordinates += 1
                addCoordinateToPath(coordinates)
                calculatePathInfo()
                trackCoordinates.append(coordinates)
                
                if countCoordinates > 10 {
                    uploadCoordinates()
                    stopRecording()
                }
            }
            .store(in: &cancellables)
        print(cancellables.count, "cancellables.count")
    }
    
    func stopRecording() {
        timer?.invalidate()
        cancellables.removeAll()
        print(cancellables.count, "cancellables.count")
        uploadCoordinates()
    }
    
    func uploadCoordinates() {
        countCoordinates = 0
        
        guard let userProfile = AuthorizedManager.shared.userProfile else { return }
        let locationsArray = trackCoordinates
        let transformLocationsArray = locationsArray.map{LocationWrapper(coordinate: $0.coordinate)}
        
        let userTrack = UserTrack(uidUser: userProfile.uid, trackCoordinates: transformLocationsArray, userEmail: userProfile.login, managerEmail: userProfile.managerEmail, date: dateStart, trackInfo: trackInfo)
        
        Task {
            do {
                try await DatabaseManager.shared.uploadTrackToServer(uidTrack: uidUserTrack, trackModel: userTrack)
            } catch {
                self.error = error
            }
        }
    }
    
    @objc func updateTimer() {
           seconds += 1
       }
    
    private func calculatePathInfo() {
        let length = Int(GMSGeometryLength(path)) //full length in meters
        trackInfo = TrackInfoModel(trackTimeSec: seconds, distanceMeter: length)
    }
    
    private func addCoordinateToPath(_ coordinate: CLLocation) {
        path.add(coordinate.coordinate)
    }
}
