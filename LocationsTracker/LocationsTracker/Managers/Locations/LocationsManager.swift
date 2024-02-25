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
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        
        locationManager.activityType = .fitness
        
    }
    
    func start() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.showsBackgroundLocationIndicator = false
    }
    
}
