//
//  TrackViewModel.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 22.02.2024.
//

import Foundation
import Combine


class TrackViewModel {
    
    let userProfile: UserProfile?
    @Published var error: Error?
    @Published var tracksData: [[UserTrack]] = [] {
        didSet {
            print(tracksData.count)
        }
    }
    @Published var filterDate: Date?
    private var cancellable = Set<AnyCancellable>()
    private let dataBaseManager = DatabaseManager.shared
    
    init() {
        userProfile = AuthorizedManager.shared.userProfile
        
        Task {
            do {
                try await fetchTracks()
            } catch {
                self.error = error
            }
        }
    }
    
    private func fetchTracks() async throws {
        guard let userProfile else {
            print("Can't find userProfile in TrackViewModel")
            return
        }
        
        var arrayOfTracks = try await dataBaseManager.getUserTracks(uid: userProfile.uid)
        
        if userProfile.isManager {
            if let email = userProfile.managerEmail {
                let tracksUsersByManager = try await dataBaseManager.getManagerAllUsersTracks(managerEmail: email)
                arrayOfTracks.append(contentsOf: tracksUsersByManager)
            }
        }
        
        tracksData = groupElementsByDate(arrayOfTracks)
    }
    
    func numberOfItems(in section: Int) -> Int {
        tracksData[section].count
    }
    
    func numberOfSections() -> Int {
        tracksData.count
    }
    
    func titleForHeader(in section: Int) -> String? {
        let sectionData = tracksData[section]
        let countTracks = sectionData.count
        let date = sectionData.first?.date.getDateForHeader() ?? ""
        return "\(date) (\(countTracks))"
    }
    
    func groupElementsByDate(_ array: [UserTrack]) -> [[UserTrack]] {
        var result: [[UserTrack]] = []
        var currentGroup: [UserTrack] = []
        
        let sortedArray = array.sorted { $0.date < $1.date }

        for (index, element) in sortedArray.enumerated() {
            if index == 0 || Calendar.current.isDate(element.date, inSameDayAs: sortedArray[index - 1].date) {
                currentGroup.append(element)
            } else {
                result.append(currentGroup)
                currentGroup = [element]
            }
        }
        
        result.append(currentGroup)
        
        return result
    }
    
    func deleteTrack(track: UserTrack ) {
        Task {
            do {
                try await dataBaseManager.deleteDocument(track.uidDocument)
            } catch {
                self.error = error
            }
        }
    }
    
    
}



//
//    [UserTrack(userEmail: "test@test.com", date: .now, trackInfo: TrackInfoModel(trackTimeSec: 45, distanceMeter: 12503), isFinish: true)],
//    [UserTrack(userEmail: "test@test.com", date: (.now + 3600 * 25), trackInfo: TrackInfoModel(trackTimeSec: 45, distanceMeter: 1250), isFinish: false)]
