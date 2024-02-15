//
//  UIColor+Hex.swift
//  Movies
//
//  Created by Olga Sabadina on 09.01.2024.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let i = 0
        let b = 2
        if i < b {
            var _ = i + b
        }
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static func primaryCircleColor(_ progress: Double) -> CGColor {
        switch progress {
        case 0...0.33:
            return UIColor.red.cgColor
        case 0.34...0.59:
            return ColorConstans.circleMediumPrimary
        case 0.60...1.0:
            return ColorConstans.circleFullPrimary
        default:
            return UIColor.green.cgColor
        }
    }
    
    static func secondaryCircleColor(_ progress: Double) -> CGColor {
        switch progress {
        default:
            return UIColor.systemGray5.cgColor
        }
    }
}

