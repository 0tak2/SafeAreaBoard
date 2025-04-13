//
//  GetAllQuestionsUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation
import Supabase
import os.log

protocol GetAllPostsUseCaseProtocol: UseCase where Command == Int, Result == [PostWithOwnership] {
}

struct GetAllPostsUseCase: GetAllPostsUseCaseProtocol {
    private let postRepository: PostRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let log = Logger.of("GetAllQuestionsUseCase")
    
    init(postRepository: PostRepositoryProtocol, authService: AuthServiceProtocol) {
        self.postRepository = postRepository
        self.authService = authService
    }
    
    /**
     command:   조회할 포스트가 속한 질문의 id
     */
    func execute(command: Int) async throws -> [PostWithOwnership] {
        do {
            let posts = try await postRepository.getAll(questionId: command)
            
            if let myUserId = try await authService.getCurrentUser()?.id {
                return posts.map {
                    PostWithOwnership(
                        post: $0, isMine: $0.profileId == myUserId, isReactedByMyself: getIsReactedByMyself(post: $0, myUserId: myUserId)
                    )
                }
            } else {
                log.warning("session expired...")
                return posts.map { PostWithOwnership(post: $0, isMine: false, isReactedByMyself: false) }
            }
        } catch {
            log.error("postRepository error. \(error)")
            throw DomainError.dataLayerError(error.localizedDescription)
        }
    }
    
    private func getIsReactedByMyself(post: Post, myUserId: UUID) -> Bool {
        guard let reactions = post.reactions else {
            log.warning("reactions is nil")
            return false
        }
        
        return reactions.first { $0.profileId == myUserId } != nil
    }
}
