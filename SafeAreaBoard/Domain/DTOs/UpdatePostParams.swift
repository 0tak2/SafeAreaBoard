//
//  UpdatePostParams.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation

struct UpdatePostParams: Encodable {
    let content: String?
    let createdAt: Date?
    let updatedAt: Date?
    let profileId: UUID?
    let questionId: Int?
    let isDeleted: Bool?
    let isHidden: Bool?
    
    enum CodingKeys: String, CodingKey {
        case content
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case profileId = "profile_id"
        case questionId = "question_id"
        case isDeleted = "is_deleted"
        case isHidden = "is_hidden"
    }
}
