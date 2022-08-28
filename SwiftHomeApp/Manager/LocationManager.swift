//
//  LocationManager.swift
//  SwiftHomeApp
//
//  Created by 杉山優悟 on 2022/06/20.
//

import Foundation
import CoreLocation
import Combine

public class LocationManager: NSObject, ObservableObject {
    private let userLocationRelay = CurrentValueSubject<CLLocationCoordinate2D, Never>(.init(latitude: 0, longitude: 0))
    var userLocationPublisher: AnyPublisher<CLLocationCoordinate2D, Never> {
        return userLocationRelay.eraseToAnyPublisher()
    }
    private let locationManager = CLLocationManager()

    public override init() {
        super.init()

        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func updateLocation() {
        locationManager.requestLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager,didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            guard let coordinate = locationManager.location?.coordinate else { return }
            userLocationRelay.send(coordinate)
        default:
            break
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userLocationRelay.send(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

