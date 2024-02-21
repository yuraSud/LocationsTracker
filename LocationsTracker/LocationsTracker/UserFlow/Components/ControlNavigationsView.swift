//
//  ControlNavigationsView.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 16.02.2024.
//

import UIKit


class ControlNavigationsView: UIView {
    
    let timeLabel = UILabel()
    let distanceLabel = UILabel()
    let speedLabel = UILabel()
    var treckInfoStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        self.backgroundColor = .yellow
    }
    
    private func configureTreckInfoStack() {
        treckInfoStack = UIStackView(arrangedSubviews: [timeLabel, distanceLabel, speedLabel])
        treckInfoStack.axis = .horizontal
        treckInfoStack.spacing = 5
        treckInfoStack.alignment = .leading
    }
    
    
    
}
