//
//  TrackCell.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 23.02.2024.
//

import UIKit

class TrackCell: UITableViewCell {
    
    static let cellID = "TrackCell"
    
    var model: UserTrack? {
        didSet {
            setTrackInfo()
        }
    }
    
    private let userEmailLabel = UILabel()
    private let trackBeginTimeLabel = UILabel()
    private let trackDistanceLabel = UILabel()
    private let recIndicator = UIImageView(image: ImageConstants.recImage)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetDataCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    private func configureCell() {
        self.heightAnchor.constraint(equalToConstant: 63).isActive = true
        [userEmailLabel,
         trackBeginTimeLabel,
         trackDistanceLabel,
         recIndicator].forEach { addSubview($0) }
        
        userEmailLabel.font = .systemFont(ofSize: 20, weight: .bold)
        trackBeginTimeLabel.font = .systemFont(ofSize: 14)
        trackBeginTimeLabel.textColor = .gray

        trackDistanceLabel.textAlignment = .right
        
        let size = self.bounds
        userEmailLabel.frame = .init(x: 15, y: 10, width: size.width/2, height: 20)
        trackBeginTimeLabel.frame = .init(x: 15, y: 30, width: size.width/2, height: 20)
        trackDistanceLabel.frame = .init(x: size.width-90, y: 20, width: 100, height: 25)
        recIndicator.frame = .init(x: size.width-30, y: 20, width: 30, height: 30)
    }
    
    private func setTrackInfo() {
        userEmailLabel.text = model?.userEmail
        trackBeginTimeLabel.text = model?.date.getTime()
        
        if model?.isFinish ?? false {
            recIndicator.isHidden = true
            trackDistanceLabel.text = model?.trackInfo?.distanceTitle
        } else {
            recIndicator.isHidden = false
            trackDistanceLabel.text = ""
        }
    }
    
    private func resetDataCell() {
        recIndicator.isHidden = true
        userEmailLabel.text = ""
        trackBeginTimeLabel.text = ""
        trackDistanceLabel.text = ""
    }
}

