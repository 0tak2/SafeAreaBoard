//
//  Post.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation

struct Post: Decodable, Hashable {
    let id: Int?
    let content: String?
    let createdAt: Date?
    let updatedAt: Date?
    let isDeleted: Bool?
    let isHidden: Bool?
    let profileId: UUID?
    let questionId: Int?
    let profile: Profile?
    let reactions: [Reaction]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isDeleted = "is_deleted"
        case isHidden = "is_hidden"
        case profileId = "profile_id"
        case questionId = "question_id"
        case profile = "profiles"
        case reactions
    }
}
