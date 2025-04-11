//
//  Logger+Helper.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/10/25.
//

import Foundation
import os.log

extension Logger {
    static func of(_ category: String) -> Logger {
        Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.youngtaek.SafeAreaBoard", category: category)
    }
}
