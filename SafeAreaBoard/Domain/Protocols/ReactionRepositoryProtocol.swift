//
//  ReactionRepositoryProtocol.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation

protocol ReactionRepositoryProtocol {
    func getAll(postId: Int) async throws -> [Reaction]
    func insert(params: AddReactionParams) async throws -> Reaction
    func delete(reactionId: Int) async throws
    func delete(postId: Int, profileId: UUID) async throws
}
