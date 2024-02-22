//
//  TrackInfoModel.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 21.02.2024.
//

import Foundation

struct TrackInfoModel: Codable {
    var trackTime: Int
    var trackDistance: Int

    init(trackTimeSec: Int = 0, distanceMeter: Int = 0) {
        self.trackTime = trackTimeSec
        self.trackDistance = distanceMeter
    }
    
    var timeTitle: String {
        trackTime.formattedTimeFromSeconds()
    }
    
    var distanceTitle: String {
        trackDistance.formattedMeters()
    }
    
    var speedTitle: String {
        let speed = (Double(trackDistance) / 1000) / (Double(trackTime) / 3600)
        return "\(speed)km/h"
    }
}
