//
//  LocationsManager.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 16.02.2024.
//
import CoreLocation
import Foundation

class LocationManager: NSObject {
    var locationManager = CLLocationManager()
   
    override init() {
        super.init()
        setupLocationManager()
    }

    func setupLocationManager() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        
        locationManager.activityType = .fitness
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    func start() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
}
