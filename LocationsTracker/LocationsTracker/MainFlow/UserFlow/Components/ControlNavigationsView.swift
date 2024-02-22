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
    let startStopButton = UIButton()
    let pauseButton = UIButton()
    let settingsButton = UIButton()
    let trackButton = UIButton()
    var trackInfoStack = UIStackView()
    var eventCompletion: ((NavigationEvent) -> Void)?
    var isRec = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureTreckInfoStack()
        configureButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        trackInfoStack.frame = .init(x: -100, y: 20, width: 250, height: 80)
        startStopButton.frame = CGRect(x: self.bounds.midX - 25, y: 15, width: 60, height: 60)
        pauseButton.frame = CGRect(x: self.bounds.width + 5, y: 25, width: 40, height: 40)
        settingsButton.frame = CGRect(x: self.bounds.width - 70, y: 25, width: 40, height: 40)
        trackButton.frame = CGRect(x: 40, y: 25, width: 40, height: 40)
    }
    
    func updateTrackInfo(_ trackInfo: TrackInfoModel) {
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
    
    private func configureButtons() {
        let startAction = UIAction { _ in
            self.isRec.toggle()
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear) {
                self.buttonsPositions()
            }
            self.eventCompletion?(self.isRec ? .rec : .stop)
        }
        
        let settingsAction = UIAction { _ in
            self.eventCompletion?(.setting)
        }
        
        let trackAction = UIAction { _ in
            self.eventCompletion?(.track)
        }
        
        let pauseAction = UIAction { _ in
            self.eventCompletion?(.pause)
        }
        
        startStopButton.addAction(startAction, for: .touchUpInside)
        startStopButton.layer.cornerRadius = 35
        
        pauseButton.layer.cornerRadius = 30
        pauseButton.setBackgroundImage(ImageConstants.pauseRecImage, for: .normal)
        pauseButton.addAction(pauseAction, for: .touchUpInside)
        
        settingsButton.setBackgroundImage(ImageConstants.settingImage, for: .normal)
        settingsButton.addAction(settingsAction, for: .touchUpInside)
        settingsButton.tintColor = .blue
        settingsButton.layer.cornerRadius = 30
        
        trackButton.setBackgroundImage(ImageConstants.trackImage, for: .normal)
        trackButton.addAction(trackAction, for: .touchUpInside)
        trackButton.layer.cornerRadius = 30
        
        addSubview(startStopButton)
        addSubview(pauseButton)
        addSubview(settingsButton)
        addSubview(trackButton)
        
        buttonsPositions()
    }
    
    private func buttonsPositions() {
        let size = self.bounds
        let positionOne = CGRect(x: size.midX - 25, y: 15, width: 60, height: 60)
        let positionTwo = CGRect(x: size.midX + 25, y: 15, width: 60, height: 60)
        
        let positionPauseOne = CGRect(x: size.width + 5, y: 25, width: 40, height: 40)
        let positionPauseTwo = CGRect(x: size.width - 70, y: 25, width: 40, height: 40)
        
        let positionSettingsOne = CGRect(x: size.width - 70, y: 150, width: 40, height: 40)
        let positionSettingsTwo = CGRect(x: size.width - 70, y: 40, width: 40, height: 40)
        
        let positionTrackOne = CGRect(x: 40, y: 150, width: 40, height: 40)
        let positionTrackTwo = CGRect(x: 40, y: 40, width: 40, height: 40)
        
        let stackPositionOne = CGRect(x: -100, y: 20, width: 250, height: 80)
        let stackPositionTwo = CGRect(x: 40, y: 20, width: 250, height: 80)
        
        startStopButton.setBackgroundImage(isRec ?  ImageConstants.stopRecImage : ImageConstants.startRecImage , for: .normal)
        startStopButton.tintColor = isRec ? .red : .blue
        startStopButton.frame = isRec ? positionTwo : positionOne
        
        pauseButton.frame = isRec ? positionPauseTwo : positionPauseOne
        
        settingsButton.frame = isRec ? positionSettingsOne : positionSettingsTwo
        
        trackButton.frame = isRec ? positionTrackOne : positionTrackTwo
        
        trackInfoStack.frame = isRec ? stackPositionTwo : stackPositionOne
    }
    
}

enum NavigationEvent {
    case rec
    case setting
    case track
    case stop
    case pause
}
