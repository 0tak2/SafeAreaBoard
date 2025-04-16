//
//  Profile.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/11/25.
//

import Foundation

struct Profile: Decodable, Hashable {
    let userId: UUID?
    let nickname: String?
    let fcmToken: String?
    
    init(userId: UUID?, nickname: String?, fcmToken: String? = nil) {
        self.userId = userId
        self.nickname = nickname
        self.fcmToken = fcmToken
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case nickname
        case fcmToken = "fcm_token"
    }
}
