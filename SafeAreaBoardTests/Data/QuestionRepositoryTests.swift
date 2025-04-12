//
//  QuestionRepositoryTests.swift
//  SafeAreaBoardTests
//
//  Created by 임영택 on 4/12/25.
//

import Testing
@testable import SafeAreaBoard
import Foundation

struct QuestionRepositoryTests {
    private let supabaseClient: SupabaseProvider!
    private let questionRepository: QuestionRepositoryProtocol!
    
    private static let defaultUrlString: String = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_LOCAL_URL") as! String
    private static let defaultKey: String = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_LOCAL_KEY") as! String
    private let shouldSkipString: String = Bundle.main.object(forInfoDictionaryKey: "ENABLE_TEST_LOCAL_SUPABASE") as! String
    private var shouldSkip: Bool {
        shouldSkipString == "false"
    }
    
    init() {
        supabaseClient = SupabaseProvider(url: URL(string: QuestionRepositoryTests.defaultUrlString)!, key: QuestionRepositoryTests.defaultKey)
        questionRepository = QuestionRepository(supabaseClient: supabaseClient.supabase)
    }
    
    @Test func testGetAll() async throws {
        guard !shouldSkip else {
            print("test skip")
            return
        }
        
        let questions = try await questionRepository.getAll()
        print(questions)
    }
}
