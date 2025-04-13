//
//  QuestionRepository.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation
import Supabase

final class QuestionRepository: QuestionRepositoryProtocol {
    private let supabaseClient: SupabaseClient
    private let tableName = "questions"
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    func getAll() async throws -> [Question] {
        let questions: [Question] = try await supabaseClient
            .from(tableName)
            .select()
            .eq("is_hidden", value: false)
            .eq("is_deleted", value: false)
            .order("id", ascending: false)
            .execute()
            .value
        
        return questions
    }
}
