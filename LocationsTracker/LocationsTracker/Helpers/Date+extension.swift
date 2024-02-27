//
//  Date+extension.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 23.02.2024.
//

import Foundation

extension Date {
    
    func getTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    func getDateForHeader() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let date = dateFormatter.string(from: self)
        return "Tracks for: \(date)"
    }
    
    
}
