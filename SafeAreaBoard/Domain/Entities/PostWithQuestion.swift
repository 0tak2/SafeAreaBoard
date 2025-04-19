//
//  PostWithQuestion.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/18/25.
//

import Foundation

protocol PostRenderable {
    var id: Int? { get }
    var content: String? { get }
    var createdAt: Date? { get }
    var updatedAt: Date? { get }
    var profileId: UUID? { get }
    var profile: Profile? { get }
    var isMine: Bool { get }
    var questionId: Int? { get }
    var reactions: [Reaction]? { get }
    var isReactedByMyself: Bool { get } // 내가 좋아요 눌렀는지 여부
}

struct PostWithQuestion: PostRenderable {
    let id: Int?
    let content: String?
    let createdAt: Date?
    let updatedAt: Date?
    let profileId: UUID?
    let profile: Profile?
    let isMine: Bool
    let questionId: Int?
    let question: Question?
    let reactions: [Reaction]?
    let isReactedByMyself: Bool // 내가 좋아요 눌렀는지 여부
}
