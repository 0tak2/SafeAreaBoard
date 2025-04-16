//
//  UpdateProfileParams.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/11/25.
//

import Foundation

struct UpdateFCMTokenProfileParams: Encodable {
    @NullEncodable var fcmToken: String?
    
    enum CodingKeys: String, CodingKey {
        case fcmToken = "fcm_token"
    }
}
