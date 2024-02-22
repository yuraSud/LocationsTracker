//
//  TrackViewModel.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 22.02.2024.
//

import Foundation


class TrackViewModel {
    
    var tracksData = [[UserTrack]]()
    var filterDate: Date?
    
    func numberOfItems(in section: Int) -> Int {
        tracksData[section].count
    }
    
    func numberOfSections() -> Int {
        tracksData.count
    }
}
