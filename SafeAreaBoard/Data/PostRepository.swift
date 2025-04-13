//
//  PostRepository.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation
import Supabase

final class PostRepository: PostRepositoryProtocol {
    private let supabaseClient: SupabaseClient
    private let tableName = "posts"
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    func getAll(questionId: Int) async throws -> [Post] {
        let posts: [Post] = try await supabaseClient
            .from(tableName)
            .select("*, profiles(*), reactions(*)")
            .eq("question_id", value: questionId)
            .eq("is_deleted", value: false)
            .eq("is_hidden", value: false)
            .order("id", ascending: false)
            .execute()
            .value
        
        return posts
    }
    
    func getOne(postId: Int) async throws -> Post? {
        let post: Post = try await supabaseClient
            .from(tableName)
            .select("*, profiles(*), reactions(*)")
            .eq("id", value: postId)
            .eq("is_deleted", value: false)
            .eq("is_hidden", value: false)
            .single()
            .execute()
            .value
        
        return post
    }
    
    func insert(params: UpdatePostParams) async throws -> Post {
        let post: Post = try await supabaseClient
            .from(tableName)
            .insert(params)
            .select()
            .single()
            .execute()
            .value
        
        return post
    }
    
    func update(postId: Int, params: UpdatePostParams) async throws -> Post {
        let post: Post = try await supabaseClient
            .from(tableName)
            .update(params)
            .eq("id", value: postId)
            .select()
            .single()
            .execute()
            .value
        
        return post
    }
    
    func delete(postId: Int) async throws {
        guard let post = try await getOne(postId: postId) else {
            throw NSError(domain: "not found", code: 404) // FIXME: make custom error
        }
        
        try await supabaseClient
            .from(tableName)
            .update(UpdatePostParams(
                content: post.content,
                createdAt: post.createdAt,
                updatedAt: Date(),
                profileId: post.profileId,
                questionId: post.questionId,
                isDeleted: true,
                isHidden: post.isHidden
            ))
            .eq("id", value: postId)
            .execute()
    }
}
