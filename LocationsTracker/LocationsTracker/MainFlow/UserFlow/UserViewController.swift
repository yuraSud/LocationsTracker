//
//  UserViewController.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 15.02.2024.
//


import UIKit
import GoogleMaps
import CoreLocation
import Combine

class UserViewController: UIViewController {
    
    private var mapView: GMSMapView!
    private let locationManager = LocationManager()
    private let vm = UserViewModel()
    private let controlView = ControlNavigationsView()
    private var cancellables = Set<AnyCancellable>()
    private var movementDirection: CLLocationDirection = .zero
    let polyline = GMSPolyline()
    
    //MARK: - Life Cycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        configureControlView()
        sinkToProperties()
        controlEvents()
    }
    
    private func sinkToProperties() {
        vm.$trackCoordinates
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else {return}
                drawPath()
                controlView.updateTrackInfo(vm.trackInfo)
        }
            .store(in: &cancellables)
    }

    private func setupMapView() {
        let options = GMSMapViewOptions()
        mapView = GMSMapView(options:options)
        view.addSubview(mapView)
        mapView.frame = .init(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 120)
        mapView.delegate = self
        mapView.isIndoorEnabled = true // default equal true
        mapView.mapType = .normal
        mapView.isMyLocationEnabled = true //мое местоположение и копмас
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        locationManager.locationManager.delegate = self
        
        guard let myPosition = locationManager.locationManager.location?.coordinate
         else {
            print("not receive start coordinate")
            return
        }
        mapView.camera = GMSCameraPosition(target: myPosition, zoom: 18, bearing: 0, viewingAngle: 0)
    }
    
    private func configureControlView() {
        controlView.frame = .init(x: 0, y: view.bounds.height - 130, width: view.bounds.width, height: 150)
        view.addSubview(controlView)
    }
    
    func startRecording() {
        mapView.clear()
        
        polyline.strokeWidth = 4.0
        polyline.map = mapView
        
        guard let startTrackPosition = locationManager.locationManager.location
        else {
            print("not receive start coordinate")
            return
        }
        addMarker(position: startTrackPosition.coordinate, title: "Start", description: "This is start coordinate of your track", icon: ImageConstants.start)
        vm.startRecording()
        vm.currentCoordinates = startTrackPosition
    }
    
    func stopRecording() {
        vm.stopRecording()
        
        //scale full path to screen
        let bounds = GMSCoordinateBounds(path: vm.path)
        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
        
        guard let endTrackPosition = vm.trackCoordinates.last?.coordinate else { return }
        addMarker(position: endTrackPosition, title: "End position", description: "This is end point of your track", icon: ImageConstants.end)
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
    
    private func controlEvents() {
        controlView.eventCompletion = { [weak self] event in
            guard let self else {return}
            switch event {
            case .rec:
                startRecording()
            case .setting:
                let settingsVC = SettingsViewController()
                settingsVC.sheetPresentationController?.detents = [.medium()]
                navigationController?.present(settingsVC, animated: true)
            case .track:
                let trackVC = TracksViewController()
                navigationController?.pushViewController(trackVC, animated: true)
            case .stop:
                stopRecording()
            case .pause:
                vm.pauseRecTrack()
            }
        }
    }
}

extension UserViewController {
    
    @MainActor
    private func drawPath() {
        polyline.path = vm.path
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

extension UserViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("user notDetermined access gps")
        case .denied:
            print("user denied access gps")
        case .authorizedAlways:
            print("user authorizedAlways access gps")
        case .authorizedWhenInUse:
            print("user authorizedWhenInUse access gps")
        default:
            print("unknow status gps")
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first, vm.isRecording else { return }
        
        vm.currentCoordinates = currentLocation
        
        let newCameraPosition = GMSCameraPosition(target: currentLocation.coordinate, zoom: 18, bearing: currentLocation.course, viewingAngle: 30)
    
        mapView.animate(to: newCameraPosition)   
    }
}

extension UserViewController: GMSMapViewDelegate {
    
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