//
//  Reaction.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation

struct Reaction: Decodable {
    let id: Int?
    let type: String?
    let createdAt: Date?
    let profileId: UUID?
    let profile: Profile?
    let postId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case createdAt = "created_at"
        case profileId = "profile_id"
        case profile = "profiles"
        case postId = "post_id"
    }
}
