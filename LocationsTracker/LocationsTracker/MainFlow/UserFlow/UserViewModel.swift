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
    @Published var trackCoordinates = [CLLocation]() {
        didSet {
            print(trackCoordinates.count, "-", countCoordinates)
        }
    }
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    private var countCoordinates = 0
    private var timer: Timer?
    private var seconds = 0
    private var dateStart: Date = .now
    
    var trackInfo = TrackInfoModel()
    let path = GMSMutablePath()
    var uidUserTrack: String = ""
    var isRecording = false
    
    init() {}
    
    func startRecording() {
        isRecording = true
        trackCoordinates = []
        countCoordinates = 0
        seconds = 0
        timer = nil
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
                uploadCoordinates()
            }
            .store(in: &cancellables)
    }
    
    func pauseRecTrack() {
        isRecording.toggle()
    
        if isRecording {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        } else {
            timer?.invalidate()
        }
    }
    
    func stopRecording() {
        isRecording = false
        timer?.invalidate()
        cancellables.removeAll()
        uploadCoordinates(isFinish: true)
    }
    
    func uploadCoordinates(isFinish: Bool = false) {
        guard countCoordinates > 8 || isFinish else { return }
        countCoordinates = 0
        
        guard let userProfile = AuthorizedManager.shared.userProfile else { return }
        let locationsArray = trackCoordinates
        let transformLocationsArray = locationsArray.map{LocationWrapper(coordinate: $0.coordinate)}
        
        let userTrack = UserTrack(uidUser: userProfile.uid, trackCoordinates: transformLocationsArray, userEmail: userProfile.login, managerEmail: userProfile.managerEmail, date: dateStart, trackInfo: trackInfo, isFinish: isFinish)
        print("prepare track")
        Task {
            do {
                try await DatabaseManager.shared.uploadTrackToServer(uidTrack: uidUserTrack, trackModel: userTrack)
                print("upload track")
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
