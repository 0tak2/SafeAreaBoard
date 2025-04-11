//
//  Profile.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/11/25.
//

import Foundation

struct Profile: Decodable {
    let userId: UUID?
    let nickname: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case nickname
    }
}
