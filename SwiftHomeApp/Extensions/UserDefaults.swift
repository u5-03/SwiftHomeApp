//
//  UserDefaults.swift
//  SwiftHomeApp
//
//  Created by yugo.sugiyama on 2022/08/13.
//

import Foundation

private enum UserDefaultsKey: String {
    case latitude
    case longitude
    case absoluteAltimeter
    case suicaId
}

extension UserDefaults {
    var latitude: Double {
        get {
            return UserDefaults.standard.double(forKey: UserDefaultsKey.latitude.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.latitude.rawValue)
        }
    }
    var longitude: Double {
        get {
            return UserDefaults.standard.double(forKey: UserDefaultsKey.longitude.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.longitude.rawValue)
        }
    }
    var absoluteAltimeter: Double {
        get {
            return UserDefaults.standard.double(forKey: UserDefaultsKey.absoluteAltimeter.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.absoluteAltimeter.rawValue)
        }
    }
    var suicaId: String? {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultsKey.suicaId.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.suicaId.rawValue)
        }
    }
}
