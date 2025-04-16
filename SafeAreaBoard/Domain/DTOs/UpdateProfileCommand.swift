//
//  UpdateProfileCommand.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/11/25.
//

import Foundation

struct UpdateProfileCommand<T> {
    let userId: UUID
    let params: T
}
