//
//  AddReactionParams.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation

struct AddReactionParams: Encodable {
    let type: String?
    let createdAt: Date?
    let profileId: UUID?
    let postId: Int?
    
    enum CodingKeys: String, CodingKey {
        case type
        case createdAt = "created_at"
        case profileId = "profile_id"
        case postId = "post_id"
    }
}
