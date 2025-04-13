//
//  Post.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation

struct PostWithOwnership {
    let id: Int?
    let content: String?
    let createdAt: Date?
    let updatedAt: Date?
    let isDeleted: Bool?
    let isHidden: Bool?
    let profileId: UUID?
    let isMine: Bool
    let questionId: Int?
    let profile: Profile?
    let reactions: [Reaction]?
    
    init(id: Int?, content: String?, createdAt: Date?, updatedAt: Date?, isDeleted: Bool?, isHidden: Bool?, profileId: UUID?, isMine: Bool, questionId: Int?, profile: Profile?, reactions: [Reaction]?) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDeleted = isDeleted
        self.isHidden = isHidden
        self.profileId = profileId
        self.isMine = isMine
        self.questionId = questionId
        self.profile = profile
        self.reactions = reactions
    }
    
    init(post: Post, isMine: Bool) {
        self.id = post.id
        self.content = post.content
        self.createdAt = post.createdAt
        self.updatedAt = post.updatedAt
        self.isDeleted = post.isDeleted
        self.isHidden = post.isHidden
        self.profileId = post.profileId
        self.isMine = isMine
        self.questionId = post.questionId
        self.profile = post.profile
        self.reactions = post.reactions
    }
}
