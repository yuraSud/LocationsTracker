//
//  Int+Extension.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 21.02.2024.
//

import Foundation

extension Int {
    
    func formattedTimeFromSeconds() -> String {
        let minutes = (self / 60) % 60
        let seconds = self % 60
        let hours = (self / 3600) % 24
        if hours > 0 {
            return String(format: "%02d h : %02d min", hours, minutes)
        } else {
            return String(format: "%02d : %02d sec", minutes, seconds)
        }
    }
    
    func formattedMeters() -> String {
        let km = self / 1000
        let reminingMeter = self % 1000
        
        if km < 1 {
            return "\(self) m"
        } else {
            return "\(km),\(reminingMeter) km"
        }
    }
}
