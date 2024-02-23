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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.red
    }
    
    private func sinkToProperties() {
//        vm.$trackCoordinates
//            .dropFirst()
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _ in
//                guard let self else {return}
//                drawPath()
//                controlView.updateTrackInfo(vm.trackInfo)
//        }
//            .store(in: &cancellables)
    }

    private func setupMapView() {
        let options = GMSMapViewOptions()
        mapView = GMSMapView(options:options)
        view.addSubview(mapView)
        mapView.frame = view.bounds
        mapView.delegate = self
        mapView.mapType = .hybrid
        mapView.isMyLocationEnabled = true //мое местоположение и копмас
        mapView.settings.compassButton = true
        
        
     //   mapView.camera = GMSCameraPosition(target: myPosition, zoom: 18, bearing: 0, viewingAngle: 0)
    }
    
    private func configureTrackInfoView() {
        trackInfoView.frame = .init(x: view.bounds.width - 140, y: 60, width: view.bounds.width / 3, height: view.bounds.height / 6)
        view.addSubview(trackInfoView)
    }
   
    ///check adress from coordinates
    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(),
                  let lines = address.lines
            else { return }
            print(coordinate)
            UIView.animate(withDuration: 0.25) {
                print(lines, "\n\n")
            }
        }
    }
}

extension PathViewController {
    
    @MainActor
    private func drawPath() {
      //  polyline.path = vm.path
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
    
    ///tap on markers
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print(marker.position, "didTap marker")
        mapView.animate(toLocation: marker.position)
        return true
      }
}

