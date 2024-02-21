//
//  UserViewController.swift
//  LocationsTracker
//
//  Created by Yura Sabadin on 15.02.2024.
//


import UIKit
import GoogleMaps
import CoreLocation


class UserViewController: UIViewController {
    
    private var timer: Timer?
    private var mapView: GMSMapView!
    private let locationManager = LocationManager()
    let markerMyPosition = GMSMarker()
    let startMarker = GMSMarker()
    let vm = UserMapViewModel()
    let controlView = ControlNavigationsView()
    
    let path = GMSMutablePath()
    var polyline = GMSPolyline()
    
    
    //MARK: - Life Cycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        let camera = GMSCameraPosition.camera(withLatitude: 37.3611824, longitude: -120.45024, zoom: 12.0)
        mapView.camera = camera//GMSCameraPosition(target: currentLocation.coordinate, zoom: 12, bearing: 0, viewingAngle: 0)
        drawPath()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.path.addLatitude(37.37571308310615, longitude: -120.4601549729705)
           
            self.mapView.clear()

            self.polyline = GMSPolyline(path: self.path)
            
            self.polyline.map = self.mapView
            
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: 37.37571308310615, longitude: -120.4601549729705) )
            marker.title = "End Marker"
            marker.map = self.mapView
            
            self.calculatePathInfo()
           
        }
    }
    
    func calculatePathInfo() {
            let length = GMSGeometryLength(path)

        print("Length of path: \(length/1000) km")

            // Assuming an average speed (e.g., 50 km/h)
            let averageSpeed = 50.0 // in kilometers per hour

            // Calculate time
            let timeInSeconds = length / (averageSpeed * 1000 / 3600)
            let timeInMinutes = timeInSeconds / 60

            print("Estimated time of travel: \(timeInMinutes) minutes")

            // Calculate speed
            let speed = length / timeInSeconds

            print("Average speed: \(speed) meters per second")
        }

    
    func drawPath() {
        

        // Add your coordinates here
        path.addLatitude(37.3611824, longitude: -120.44045750)
        path.addLatitude(37.36127147324552, longitude: -120.46833302825691)
        path.addLatitude(37.37601841648223, longitude: -120.46822104603052)

        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 4.0
     //   polyline.strokeColor = .red
        polyline.map = mapView
        
        self.markerMyPosition.title = "You are here"
        self.markerMyPosition.position = CLLocationCoordinate2D(latitude: 37.37601841648223, longitude: -120.46822104603052)
        self.markerMyPosition.map = self.mapView
        
        calculatePathInfo()
    }
    
    private func setupMapView() {
        let options = GMSMapViewOptions()
        mapView = GMSMapView(options:options)
        self.view = mapView
        mapView.delegate = self
        mapView.isIndoorEnabled = true // default equal true
        mapView.mapType = .normal
        mapView.isMyLocationEnabled = true //мое местоположение и копмас
        mapView.settings.myLocationButton = true
        locationManager.locationManager.delegate = self
    }
    
    private func configureControlView() {
        view.addSubview(controlView)
    }
    
    private func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(updateLocation), userInfo: nil, repeats: true)
    }
    
    func startRecording() {
       guard let startCoordinate = locationManager.locationManager.location?.coordinate
        else {
           print("not receive coordinate")
           return
       }
        
        startMarker.title = "Start"
        startMarker.position = startCoordinate
        startMarker.map = mapView
        setupTimer()
        //upload coordinate
    }
    
    @objc func updateLocation() {
      //  let coordinate = locationManager.locationManager.location?.coordinate
       // print(coordinate ?? "jjjkl", "one")
        // timer?.invalidate()
    }
    
    ///check adress from coordinates
    func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(),
                  let lines = address.lines
            else { return }
            
            UIView.animate(withDuration: 0.25) {
                print(lines, "\n\n")
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension UserViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D){
        reverseGeocode(coordinate: coordinate)
        print(coordinate, "coordinates from didTapAt")
    }
    
    ///tap on markers
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print(marker.position, "new")
        mapView.animate(toLocation: marker.position)
        return true
      }
}

extension UserViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
       
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else { return }
        
       // mapView.camera = GMSCameraPosition(target: currentLocation.coordinate, zoom: 12, bearing: 0, viewingAngle: 0)
        
//        markerMyPosition.title = "You are here"
//        markerMyPosition.position = currentLocation.coordinate
//        markerMyPosition.map = mapView
//        
//        vm.currentCoordinates = currentLocation
//
//        let loc2 = CLLocationCoordinate2D(latitude: 35.70895748454671, longitude: 139.78042669594288)
//        let marker2 = GMSMarker(position: loc2)
//        marker2.title = "I want go there"
//        marker2.map = mapView
       
        // marker.map = nil - delete marker
        // marker.icon = GMSMarker.markerImage(with: .black) - color marker now is black
        // marker.icon = UIImage(named: "house")
        
        // mapView.clear() - удалить все наложения на карте в том числе маркеры
    }
}
