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
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 10
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    
}
