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
    
    //MARK: - Life Cycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        configureControlView()
        sinkToProperties()
        startRecording()
    }
    
    private func sinkToProperties() {
        vm.$trackCoordinates
            //.filter{!$0.isEmpty}
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.drawPath()
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
        locationManager.locationManager.delegate = self
        
        guard let myPosition = locationManager.locationManager.location?.coordinate
         else {
            print("not receive start coordinate")
            return
        }
        mapView.camera = GMSCameraPosition(target: myPosition, zoom: 18, bearing: 0, viewingAngle: 0)
        addMarker(position: myPosition, title: "You are here", icon: ImageConstants.logoImage)
    }
    
    private func configureControlView() {
        controlView.frame = .init(x: 0, y: view.bounds.height - 130, width: view.bounds.width, height: 150)
        view.addSubview(controlView)
    }
    
    func startRecording() {
       guard let startTrackPosition = locationManager.locationManager.location
        else {
           print("not receive start coordinate")
           return
       }
        vm.startRecording()
        vm.currentCoordinates = startTrackPosition
    }
    
    ///check adress from coordinates
    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(),
                  let lines = address.lines
            else { return }
            
            UIView.animate(withDuration: 0.25) {
                print(lines, "\n\n")
              //  self.view.layoutIfNeeded()
            }
        }
    }
}

extension UserViewController {
    
    @MainActor
    private func drawPath() {
        mapView.clear()
        
        let polyline = GMSPolyline(path: vm.path)
        polyline.strokeWidth = 4.0
        polyline.map = mapView
        
        guard let startTrackPosition = vm.trackCoordinates.first?.coordinate,
            let endTrackPosition = vm.trackCoordinates.last?.coordinate
        else {
            print("Coordinate is absent")
            return
        }

        addMarker(position: startTrackPosition, title: "Start", description: "This is start coordinate of your track", icon: ImageConstants.start)
        addMarker(position: endTrackPosition, title: "End position", description: "This is end point of your track", icon: ImageConstants.end)
    }
    
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
        guard status == .authorizedWhenInUse 
        else {
            print("Need Authorization")
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else { return }
        
        mapView.camera = GMSCameraPosition(target: currentLocation.coordinate, zoom: 18, bearing: 0, viewingAngle: 0)
        
        vm.currentCoordinates = currentLocation
    }
}

extension UserViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D){
        reverseGeocode(coordinate: coordinate)
        print(coordinate, "coordinates from didTapAt")
    }
    
    ///tap on markers
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print(marker.position, "didTap marker")
        mapView.animate(toLocation: marker.position)
        
        return true
      }
}
