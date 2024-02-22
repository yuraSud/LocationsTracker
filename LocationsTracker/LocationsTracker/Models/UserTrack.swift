//
//  UserTrack.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 21.02.2024.
//

import Foundation
import GoogleMaps
import FirebaseFirestore
import CoreLocation

struct UserTrack: Codable {
    
    var uidUser: String?
    var trackCoordinates: [LocationWrapper]?
    var userEmail: String?
    var managerEmail: String?
    var date: Date?
    var trackInfo: TrackInfoModel?
    var isFinish: Bool?
    
    init(uidUser: String? = nil, trackCoordinates: [LocationWrapper]? = nil, userEmail: String? = nil, managerEmail: String? = nil, date: Date? = nil, trackInfo: TrackInfoModel? = nil, isFinish: Bool? = nil) {
        self.uidUser = uidUser
        self.trackCoordinates = trackCoordinates
        self.userEmail = userEmail
        self.managerEmail = managerEmail
        self.date = date
        self.trackInfo = trackInfo
        self.isFinish = isFinish
    }
    
    init?(qSnapShot: QueryDocumentSnapshot) {
        let data = qSnapShot.data()
        let uidUser = data["uidUser"] as? String
        let trackCoordinates = data["trackCoordinates"] as? [LocationWrapper]
        let userEmail = data["userEmail"] as? String
        let managerEmail = data["managerEmail"] as? String
        let date = data["date"] as? Date
        let trackInfo = data["trackInfo"] as? TrackInfoModel
        let isFinish = data["isFinish"] as? Bool
        
        self.uidUser = uidUser
        self.trackCoordinates = trackCoordinates
        self.userEmail = userEmail
        self.managerEmail = managerEmail
        self.date = date
        self.trackInfo = trackInfo
        self.isFinish = isFinish
    }
}

struct LocationWrapper: Codable {
    var latitude: Double
    var longitude: Double

    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

