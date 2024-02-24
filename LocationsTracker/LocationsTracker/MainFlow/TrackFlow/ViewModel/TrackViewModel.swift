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
    private var tracks: [[UserTrack]] = []
    @Published var error: Error?
    @Published var tracksData: [[UserTrack]] = []
    @Published var filterDate: Date? {
        didSet {
            if filterDate == nil {
                Task {
                    do {
                        try await fetchTracks()
                    } catch {
                        self.error = error
                    }
                }
            }
        }
    }
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
        guard let userProfile else { throw AuthorizeError.userNotFound }
        
        var arrayOfTracks = try await dataBaseManager.getUserTracks(uid: userProfile.uid)
        
        if userProfile.isManager {
            let email = userProfile.login
            let tracksUsersByManager = try await dataBaseManager.getManagerAllUsersTracks(managerEmail: email)
            arrayOfTracks.append(contentsOf: tracksUsersByManager)
        }
        
        tracksData = groupElementsByDate(arrayOfTracks)
        tracks = tracksData
    }
    
    func filterByDate() {
        
        if let filterDate {
            let calendar = Calendar.current
            var filteredArray = tracks
            
            let result = filteredArray.map { tracks in
                return tracks.filter{ calendar.isDate($0.date, inSameDayAs: filterDate)}
            }
            tracksData = result
        } else {
            tracksData = tracks
        }
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
        guard let date = sectionData.first?.date.getDateForHeader() else {
            return nil
        }
        return "\(date) (\(countTracks))"
    }
    
    func groupElementsByDate(_ array: [UserTrack]) -> [[UserTrack]] {
        var result: [[UserTrack]] = []
        var currentGroup: [UserTrack] = []
        let calendar = Calendar.current
        
        let sortedArray = array.sorted { $0.date < $1.date }

        for (index, element) in sortedArray.enumerated() {
            if index == 0 || calendar.isDate(element.date, inSameDayAs: sortedArray[index - 1].date) {
                currentGroup.append(element)
            } else {
                result.append(currentGroup)
                currentGroup = [element]
            }
        }
        
        result.append(currentGroup)
        
        return result
    }
    
    func deleteTrack(track: UserTrack, indexPath: IndexPath) {
        tracksData[indexPath.section].remove(at: indexPath.row)
        guard let uidDocument = track.uidDocument else { return }
        
        Task {
            do {
                try await dataBaseManager.deleteDocument(uidDocument)
            } catch {
                self.error = error
            }
        }
    }
}
