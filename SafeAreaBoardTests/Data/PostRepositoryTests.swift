//
//  QuestionRepositoryTests.swift
//  SafeAreaBoardTests
//
//  Created by 임영택 on 4/12/25.
//

import Testing
@testable import SafeAreaBoard
import Foundation
import Supabase

// FIXME: 병렬 테스트 실패
struct PostRepositoryTests {
    private let supabaseClient: SupabaseProvider!
    private let postRepository: PostRepositoryProtocol!
    
    private static let tableName = "posts"
    private static let defaultUrlString: String = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_LOCAL_URL") as! String
    private static let defaultKey: String = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_LOCAL_KEY") as! String
    private static let userEmail: String = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_LOCAL_ACCOUNT_EMAIL") as! String
    private static let userPw: String = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_LOCAL_ACCOUNT_PASSWORD") as! String
    private let shouldSkipString: String = Bundle.main.object(forInfoDictionaryKey: "ENABLE_TEST_LOCAL_SUPABASE") as! String
    private var shouldSkip: Bool {
        shouldSkipString == "false"
    }
    
    init() {
        supabaseClient = SupabaseProvider(url: URL(string: PostRepositoryTests.defaultUrlString)!, key: PostRepositoryTests.defaultKey)
        postRepository = PostRepository(supabaseClient: supabaseClient.supabase)
    }
    
    @Test func testGetAll() async throws {
        guard !shouldSkip else {
            print("test skip")
            return
        }
        
        let userId = try await login()
        let dataCount = 3
        
        for post in getTestData(userId: userId, count: dataCount) {
            try await supabaseClient
                .supabase
                .from(PostRepositoryTests.tableName)
                .insert(post)
                .execute()
        }
        
        let saved = try await postRepository.getAll(questionId: 1)
        #expect(saved.count == dataCount)
        
        try await supabaseClient
            .supabase
            .from(PostRepositoryTests.tableName)
            .delete()
            .neq("id", value: 0)
            .execute()
        
        try await logout()
    }
    
    @Test func testGetOne() async throws {
        guard !shouldSkip else {
            print("test skip")
            return
        }
        
        let userId = try await login()
        
        let post: UpdatePostParams = getTestData(userId: userId, count: 1).first!
        let saved: Post = try await supabaseClient
            .supabase
            .from(PostRepositoryTests.tableName)
            .insert(post)
            .select()
            .single()
            .execute()
            .value
        
        let retrieved = try await postRepository.getOne(postId: saved.id!)
        
        #expect(saved.id! == retrieved?.id!)
        
        try await supabaseClient
            .supabase
            .from(PostRepositoryTests.tableName)
            .delete()
            .neq("id", value: 0)
            .execute()
        
        try await logout()
    }
    
    @Test func testInsert() async throws {
        guard !shouldSkip else {
            print("test skip")
            return
        }
        
        let userId = try await login()
        
        let post: UpdatePostParams = getTestData(userId: userId, count: 1).first!
        let saved: Post = try await postRepository.insert(params: post)
        
        let retrieved: Post = try await supabaseClient.supabase
            .from(PostRepositoryTests.tableName)
            .select()
            .eq("id", value: saved.id!)
            .single()
            .execute()
            .value
        
        #expect(saved.id! == retrieved.id!)
        
        try await supabaseClient
            .supabase
            .from(PostRepositoryTests.tableName)
            .delete()
            .neq("id", value: 0)
            .execute()
        
        try await logout()
    }
    
    @Test func testUpdate() async throws {
        guard !shouldSkip else {
            print("test skip")
            return
        }
        
        let userId = try await login()
        
        let post: UpdatePostParams = getTestData(userId: userId, count: 1).first!
        let saved: Post = try await supabaseClient
            .supabase
            .from(PostRepositoryTests.tableName)
            .insert(post)
            .select()
            .single()
            .execute()
            .value
        
        let _: Post = try await postRepository.update(postId: saved.id!, params: .init(
            content: "Updated Entity",
            createdAt: saved.createdAt,
            updatedAt: Date(),
            profileId: saved.profileId,
            questionId: saved.questionId,
            isDeleted: saved.isDeleted,
            isHidden: saved.isHidden
        ))
        
        let retrieved: Post = try await supabaseClient.supabase
            .from(PostRepositoryTests.tableName)
            .select()
            .eq("id", value: saved.id!)
            .single()
            .execute()
            .value
        
        #expect(retrieved.content == "Updated Entity")
        
        try await supabaseClient
            .supabase
            .from(PostRepositoryTests.tableName)
            .delete()
            .neq("id", value: 0)
            .execute()
        
        try await logout()
    }
    
    @Test func testDelete() async throws {
        guard !shouldSkip else {
            print("test skip")
            return
        }
        
        let userId = try await login()
        
        let post: UpdatePostParams = getTestData(userId: userId, count: 1).first!
        let saved: Post = try await supabaseClient
            .supabase
            .from(PostRepositoryTests.tableName)
            .insert(post)
            .select()
            .single()
            .execute()
            .value
        
        try await postRepository.delete(postId: saved.id!)
        
        let retrived: Post? = try await supabaseClient.supabase
            .from(PostRepositoryTests.tableName)
            .select()
            .eq("id", value: saved.id!)
            .single()
            .execute()
            .value
        #expect(retrived?.isDeleted == true)
        
        try await supabaseClient
            .supabase
            .from(PostRepositoryTests.tableName)
            .delete()
            .neq("id", value: 0)
            .execute()
        
        try await logout()
    }
    
    // TODO: 삭제된 엔티티는 조회하지 않음을 검증하는 테스트
    // TODO: 다른 유저의 엔티티는 U, D 불가능함을 검증하는 테스트
    
    private func login() async throws -> UUID {
        let session = try await supabaseClient.supabase.auth.signIn(email: PostRepositoryTests.userEmail, password: PostRepositoryTests.userPw)
        return session.user.id
    }
    
    private func logout() async throws {
        try await supabaseClient.supabase.auth.signOut()
    }
    
    private func getTestData(userId: UUID, count: Int) -> [UpdatePostParams] {
        return (0..<count).map { index in
                .init(content: "test - \(UUID().uuidString)", createdAt: nil, updatedAt: nil, profileId: userId, questionId: 1, isDeleted: false, isHidden: false)
        }
    }
}
