//
//  UIImage+Extension.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 21.02.2024.
//

import UIKit

extension UIImage {
    func resized(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
