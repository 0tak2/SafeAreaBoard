//
//  GetAllMyPostsUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/13/25.
//

import Foundation
import Supabase
import os.log

protocol GetAllMyPostsUseCaseProtocol: UseCase where Command == Void, Result == [PostWithQuestion] {
}

struct GetAllMyPostsUseCase: GetAllMyPostsUseCaseProtocol {
    private let postRespository: PostRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let log = Logger.of("GetAllMyPostsUseCase")
    
    init(postRespository: PostRepositoryProtocol, authService: AuthServiceProtocol) {
        self.postRespository = postRespository
        self.authService = authService
    }
    
    /**
     command:   조회할 포스트가 속한 질문의 id
     */
    func execute(command: Void) async throws -> [PostWithQuestion] {
        do {
            if let myUserId = try await authService.getCurrentUser()?.id {
                let posts: [Post] = try await postRespository.getAll(userId: myUserId)
                return posts.map {
                    PostWithQuestion(
                        id: $0.id,
                        content: $0.content,
                        createdAt: $0.createdAt,
                        updatedAt: $0.updatedAt,
                        profileId: $0.profileId,
                        profile: $0.profile,
                        isMine: $0.profileId == myUserId,
                        questionId: $0.questionId,
                        question: $0.question,
                        reactions: $0.reactions,
                        isReactedByMyself: getIsReactedByMyself(post: $0, myUserId: myUserId)
                    )
                }
            } else {
                log.warning("session expired...")
                return []
            }
        } catch {
            log.error("postRepository error. \(error)")
            throw DomainError.dataLayerError(error.localizedDescription)
        }
    }
    
    
    // FIXME: Duplicated
    private func getIsReactedByMyself(post: Post, myUserId: UUID) -> Bool {
        guard let reactions = post.reactions else {
            log.warning("reactions is nil")
            return false
        }
        
        return reactions.first { $0.profileId == myUserId } != nil
    }
}
