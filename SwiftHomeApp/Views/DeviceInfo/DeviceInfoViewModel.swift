//
//  DeviceInfoViewModel.swift
//  SwiftHomeApp
//
//  Created by yugo.sugiyama on 2022/08/13.
//

import UIKit
import Combine
import CoreLocation
import Vapor
import Alamofire
import SwiftHomeCredentials
import SwiftHomeCore
import SwiftExtensions

struct SwitchBotRequest: Encodable {
    let command: String
    let commandType: String
    let parameter: String
}

final class DeviceInfoViewModel: ObservableObject {
    @Published private(set) var atmosphericPressure: Double = 0
    @Published private(set) var absoluteAltimeterValue: Double = 0
    @Published private(set) var relativeAltimeterValue: Double = 0
    @Published private(set) var userCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    @Published private(set) var savedAbsoluteAltimeterValue: Double = 0
    @Published private(set) var savedUserCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    private let altimeterManager = AltimeterManager()
    private let locationManager = LocationManager()
    private var cancellableSet = Set<AnyCancellable>()
    private var webSocket: WebSocket?
    let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 2)

    private let serverConfig: ServerConfiguration = .localHost

    func setup() {
        setupObservers()
        altimeterManager.startUpdate()
        locationManager.updateLocation()
        updateDisplayedSavedData()
    }

    func onClose() {
        altimeterManager.stopUpdate()
    }

    func resetAltimeter() {
        altimeterManager.reset()
    }

    func updateUserLocation() {
        locationManager.updateLocation()
    }

    func saveData() {
        UserDefaults.standard.latitude = userCoordinate.latitude
        UserDefaults.standard.longitude = userCoordinate.longitude
        UserDefaults.standard.absoluteAltimeter = absoluteAltimeterValue
        updateDisplayedSavedData()
        postDeviceInfo()
    }

    func resetSavedData() {
        UserDefaults.standard.latitude = 0
        UserDefaults.standard.longitude = 0
        UserDefaults.standard.absoluteAltimeter = 0
        updateDisplayedSavedData()
    }

    // TODO: run when the device is in GeoFence.
    private func postDeviceInfo() {
        let encoder = JSONEncoder()
        let model = DeviceInfoModel(deviceId: UIDevice.current.identifierForVendor!.uuidString,
                                    deviceLatitude: userCoordinate.latitude,
                                    deviceLongitude: userCoordinate.longitude,
                                    absoluteAltimeter: absoluteAltimeterValue)
        let parameters = try! model.asDictionary(using: encoder)
        let basicAuthentication = SwiftHomeCredentials.basicAuthentication
        let plainString = "\(basicAuthentication.id):\(basicAuthentication.password)".data(using: String.Encoding.utf8)
        let credential = plainString?.base64EncodedString(options: [])
        let headers: Alamofire.HTTPHeaders = [
            "Authorization": "Basic \(credential!)"
        ]
        let urlString = "\(serverConfig.URLString(type: .api))/\(EndPointKind.deviceInfo.endPoint)"
        AF.request(urlString,
                   method: .post,
                   parameters: parameters,
                   headers: headers)
        // If 'emptyResponseCodes' is not specified, an error will occur if the response is empty.
        .responseDecodable(of: Empty.self, emptyResponseCodes: [200]) { response in
            switch response.result {
            case .success:
                print("Success")
            case .failure(let error):
                print(error)
            }
        }
    }

    private func updateDisplayedSavedData() {
        savedAbsoluteAltimeterValue = UserDefaults.standard.absoluteAltimeter
        savedUserCoordinate = .init(latitude: UserDefaults.standard.latitude, longitude: UserDefaults.standard.longitude)
    }

    private func setupObservers() {
        altimeterManager.atmosphericPressurePublisher
            .assign(to: &$atmosphericPressure)
        altimeterManager.relativeAltimeterPublisher
            .assign(to: &$relativeAltimeterValue)
        altimeterManager.absoluteAltimeterPublisher
            .assign(to: &$absoluteAltimeterValue)
        locationManager.userLocationPublisher
            .assign(to: &$userCoordinate)
    }
}
