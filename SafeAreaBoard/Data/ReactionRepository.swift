//
//  ReactionRepository.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation
import Supabase

final class ReactionRepository: ReactionRepositoryProtocol {
    private let supabaseClient: SupabaseClient
    private let tableName = "reactions"
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    func getAll(postId: Int) async throws -> [Reaction] {
        let reactions: [Reaction] = try await supabaseClient
            .from(tableName)
            .select()
            .eq("post_id", value: postId)
            .eq("is_deleted", value: false)
            .eq("is_hidden", value: false)
            .execute()
            .value
        
        return reactions
    }
    
    func insert(params: AddReactionParams) async throws -> Reaction {
        let reaction: Reaction = try await supabaseClient
            .from(tableName)
            .insert(params)
            .select()
            .single()
            .execute()
            .value
        
        return reaction
    }
    
    func delete(reactionId: Int) async throws {
        try await supabaseClient
            .from(tableName)
            .delete()
            .eq("id", value: reactionId)
            .execute()
    }
}
