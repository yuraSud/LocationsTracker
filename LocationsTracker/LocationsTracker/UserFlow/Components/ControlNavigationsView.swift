//
//  ControlNavigationsView.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 16.02.2024.
//

import UIKit


class ControlNavigationsView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        self.backgroundColor = .yellow
    }
    
}
