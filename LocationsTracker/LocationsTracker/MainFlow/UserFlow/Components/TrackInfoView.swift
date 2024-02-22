//
//  TrackInfoView.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 22.02.2024.
//

import UIKit

class TrackInfoView: UIView {
    
    let timeLabel = UILabel()
    let distanceLabel = UILabel()
    let speedLabel = UILabel()
    var trackInfoStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureTreckInfoStack()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        trackInfoStack.frame = .init(x: 10, y: 10, width: self.bounds.width - 20, height: self.bounds.height - 20)
    }
    
    func updateInfoAfterStopedTrack(_ trackInfo: TrackInfoModel) {
        timeLabel.text = trackInfo.timeTitle
        distanceLabel.text = trackInfo.distanceTitle
        speedLabel.text = trackInfo.speedTitle
    }
    
    private func configureView() {
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        self.backgroundColor = .white
        self.layer.borderWidth = 0.6
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.setShadow(colorShadow: .gray, offset: .zero, opacity: 0.6, radius: 8, cornerRadius: 15)
    }
    
    private func configureTreckInfoStack() {
        trackInfoStack = UIStackView(arrangedSubviews: [timeLabel, distanceLabel, speedLabel])
        trackInfoStack.axis = .vertical
        trackInfoStack.spacing = 5
        trackInfoStack.alignment = .leading
        trackInfoStack.distribution = .fillEqually
        addSubview(trackInfoStack)
    }
    
}
