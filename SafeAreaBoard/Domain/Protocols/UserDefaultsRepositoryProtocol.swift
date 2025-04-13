//
//  UserDefaultsRepositoryProtocol.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/13/25.
//

import Foundation

protocol UserDefaultsRepositoryProtocol {
    func set<T>(_ value: T, forKey key: UserDefaultsKey)
    func get<T>(key: UserDefaultsKey) -> T?
}

enum UserDefaultsKey: String {
    case lastSelectedQuestionId
}
