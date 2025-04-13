//
//  UserDefaultsRepository.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/13/25.
//

import Foundation
import os.log

final class UserDefaultsRepository: UserDefaultsRepositoryProtocol {
    private let userDefaults: UserDefaults
    
    private let log = Logger.of("UserDefaultsRepository")
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    func set<T>(_ value: T, forKey key: UserDefaultsKey) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    func get<T>(key: UserDefaultsKey) -> T? {
        switch T.self {
        case is String.Type:
            return userDefaults.string(forKey: key.rawValue) as? T
        case is Int.Type:
            return userDefaults.integer(forKey: key.rawValue) as? T
        case is Bool.Type:
            return userDefaults.bool(forKey: key.rawValue) as? T
        case is Double.Type:
            return userDefaults.double(forKey: key.rawValue) as? T
        case is Data.Type:
            return userDefaults.data(forKey: key.rawValue) as? T
        case is URL.Type:
            return userDefaults.url(forKey: key.rawValue) as? T
        default:
            log.warning("not supported type")
            return userDefaults.string(forKey: key.rawValue) as? T
        }
    }
}
