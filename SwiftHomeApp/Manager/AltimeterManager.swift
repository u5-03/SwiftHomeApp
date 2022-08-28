//
//  AltimeterManager.swift
//  SwiftHomeApp
//
//  Created by 杉山優悟 on 2022/06/19.
//

import Foundation
import CoreMotion
import Combine

final class AltimeterManager {
    private let atmosphericPressureRelay = CurrentValueSubject<Double, Never>(0)
    private let absoluteAltimeterRelay = CurrentValueSubject<Double, Never>(0)
    private let relativeAltimeterRelay = CurrentValueSubject<Double, Never>(0)
    var atmosphericPressurePublisher: AnyPublisher<Double, Never> {
        return atmosphericPressureRelay.eraseToAnyPublisher()
    }
    var absoluteAltimeterPublisher: AnyPublisher<Double, Never> {
        return absoluteAltimeterRelay.eraseToAnyPublisher()
    }
    var relativeAltimeterPublisher: AnyPublisher<Double, Never> {
        return relativeAltimeterRelay.eraseToAnyPublisher()
    }
    
    private let altimeterMeter = CMAltimeter()
    
    func reset() {
        stopUpdate()
        startUpdate()
    }
    
    func startUpdate() {
        if CMAltimeter.isAbsoluteAltitudeAvailable() {
            altimeterMeter.startAbsoluteAltitudeUpdates(to: OperationQueue.main) { data, error in
                if error != nil { return }
                self.absoluteAltimeterRelay.send(data!.altitude)
            }
            altimeterMeter.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler: { data, error in
                if error != nil { return }
                self.atmosphericPressureRelay.send(data!.pressure.doubleValue)
                self.relativeAltimeterRelay.send(data!.relativeAltitude.doubleValue)
                print("Relative Altimeter: \(data!.relativeAltitude.doubleValue)m")
            })
        }
    }

    func stopUpdate() {
        altimeterMeter.stopAbsoluteAltitudeUpdates()
        altimeterMeter.stopRelativeAltitudeUpdates()
    }
}
