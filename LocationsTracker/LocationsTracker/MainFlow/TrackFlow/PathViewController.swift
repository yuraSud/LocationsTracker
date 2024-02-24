//
//  PathViewController.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 23.02.2024.
//

import UIKit
import GoogleMaps
import CoreLocation
import Combine

class PathViewController: UIViewController {
    
    private var mapView: GMSMapView!
    private let vm: PathViewModel
    private let trackInfoView = TrackInfoView()
    private var cancellables = Set<AnyCancellable>()
    private let polyline = GMSPolyline()
    private lazy var closeButton = UIButton(frame: .init(x: 20, y: 50, width: 36, height: 36))
    private var infoMarker = GMSMarker()
    
    init(_ model: UserTrack) {
        vm = PathViewModel(model: model)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        configureTrackInfoView()
        sinkToProperties()
        configureCloseButton()
    }
    
    private func sinkToProperties() {
        vm.$isReload
            .filter{$0 == true}
            .sink { [weak self] _ in
                guard let self,
                let isFinished = vm.model.isFinish else { return }
                
                drawPathByMap(isFinished)
        }
            .store(in: &cancellables)
        vm.isReload = true
    }
    
    private func drawPathByMap(_ isFinished: Bool) {
        vm.createPathTrack()
        mapView.clear()
        
        polyline.strokeWidth = 4.0
        polyline.map = mapView
        polyline.strokeColor = .green
        
        guard let startCoordinate = vm.model.trackCoordinates?.first?.coordinate,
              let endCoordinate = vm.model.trackCoordinates?.last?.coordinate
        else { return }
        
        addMarker(position: startCoordinate, title: "Start", description: "This is start coordinate of your track", icon: ImageConstants.start)
        
        if isFinished {
            addMarker(position: endCoordinate, title: "End position", description: "This is end point of your track", icon: ImageConstants.end)
        } else {
            addMarker(position: endCoordinate, title: "You are here", description: "This is end point of your track", icon: ImageConstants.location)
        }
        drawPath()
    }

    private func setupMapView() {
        let options = GMSMapViewOptions()
        mapView = GMSMapView(options:options)
        view.addSubview(mapView)
        mapView.frame = view.bounds
        mapView.delegate = self
        mapView.mapType = .hybrid
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true //мое местоположение и копмас
        mapView.settings.compassButton = true
    }
    
    private func configureTrackInfoView() {
        trackInfoView.frame = .init(x: view.bounds.width - 140, y: 60, width: view.bounds.width / 3, height: view.bounds.height / 6)
        view.addSubview(trackInfoView)
        guard let trackInfo = vm.model.trackInfo else {return}
        trackInfoView.updateInfoAfterStopedTrack(trackInfo)
    }
    
    private func configureCloseButton() {
        let closeAction = UIAction { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        closeButton.setImage(ImageConstants.clear, for: .normal)
        closeButton.setBorderLayer(backgroundColor: .white, borderColor: .gray, borderWidth: 2, cornerRadius: 18, tintColor: .black)
        closeButton.addAction(closeAction, for: .touchUpInside)
        view.addSubview(closeButton)
    }
   
    ///check adress from coordinates
    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { [weak self] response, error in
            guard let address = response?.firstResult(),
                  let self
            else { return }
        
            infoMarker.position = coordinate
            infoMarker.title = "\(address.country ?? ""), \(address.administrativeArea ?? ""), \(address.locality ?? "")"
            infoMarker.snippet = "Postal code:\(address.postalCode ?? "none"), \ncoordinate:(\(address.coordinate.latitude), \(address.coordinate.longitude)"
            infoMarker.map = mapView
            
            infoMarker.infoWindowAnchor = CGPoint(x: 0.5, y: 0)
            mapView.selectedMarker = infoMarker
            
        }
    }
}

extension PathViewController {
    
    @MainActor
    private func drawPath() {
        polyline.path = vm.path
        let camera = mapView.camera(for: .init(path: vm.path), insets: .init(top: 100, left: 100, bottom: 100, right: 100))
        mapView.animate(to: camera!)
    }
    
    @MainActor
    private func addMarker(position: CLLocationCoordinate2D, title: String? = nil, description: String? = nil, icon: UIImage? = nil) {
        let marker = GMSMarker()
        marker.title = title
        marker.snippet = description
        marker.position = position
        marker.icon = icon?.resized(to: .init(width: 45, height: 45))
        marker.map = mapView
    }
}

extension PathViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D){
        reverseGeocode(coordinate: coordinate)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let position = GMSCameraPosition(target: marker.position, zoom: 18)
        mapView.animate(to: position)
        
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0)
        marker.snippet = "latitude:\( marker.position.latitude),\n longitude:\(marker.position.longitude)"
        mapView.selectedMarker = marker
        
        return true
      }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        mapView.selectedMarker = nil
        infoMarker.map = nil
    }
}

