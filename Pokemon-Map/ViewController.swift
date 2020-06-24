//
//  ViewController.swift
//  Pokemon-Map
//
//  Created by Kenta Terada on 2020/06/24.
//  Copyright © 2020 Kenta Terada. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!

    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var currentLocation: CLLocation?
    var locations: [Location]?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self
        self.locationManager.delegate = self

        self.locationManager.requestWhenInUseAuthorization()

        self.setRegion(35.68074968865632, 139.7672131714134)
        self.locations = self.loadLocations()
    }

    private func setRegion(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        let span = MKCoordinateSpan.init(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let region = MKCoordinateRegion.init(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }

    private func loadLocations() -> [Location]? {
        guard let path = Bundle.main.path(forResource: "locations", ofType: "json") else { return nil }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        guard var locations = try? JSONDecoder().decode([Location].self, from: data) else { return nil }
        locations = locations.filter { !$0.location.contains("どうろ") && !$0.location.contains("すいどう") }
        return locations
    }

}

extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            self.locationManager.distanceFilter = 10
            self.locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        if self.currentLocation == nil {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            self.setRegion(latitude, longitude)
        }
        self.currentLocation = location
    }

}

extension ViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        guard let location = self.getNearestLocation(Float(latitude), Float(longitude)) else { return }
        self.locationLabel.text = location.location
    }

    private func getNearestLocation(_ latitude: Float, _ longitude: Float) -> Location? {
        var nearestLocation: Location? = nil
        var minimumCost: Float = Float.greatestFiniteMagnitude
        self.locations?.forEach { location in
            let cost = pow((location.latitude - latitude), 2) + pow((location.longitude - longitude), 2)
            if cost < minimumCost {
                minimumCost = cost
                nearestLocation = location
            }
        }
        return nearestLocation
    }

}
