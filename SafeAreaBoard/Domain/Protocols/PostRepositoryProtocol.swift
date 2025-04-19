//
//  PostRepositoryProtocol.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation

protocol PostRepositoryProtocol {
    func getAll(userId: UUID) async throws -> [Post]
    func getAll(questionId: Int) async throws -> [Post]
    func getOne(postId: Int) async throws -> Post?
    func getOne(questionId: Int, profileId: UUID) async throws -> Post?
    func insert(params: UpdatePostParams) async throws -> Post
    func update(postId: Int, params: UpdatePostParams) async throws -> Post
    func delete(postId: Int) async throws
}
