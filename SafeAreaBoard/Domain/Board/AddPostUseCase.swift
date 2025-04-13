//
//  SavePostUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/13/25.
//

import Foundation
import Supabase
import os.log

protocol AddPostUseCaseProtocol: UseCase where Command == UpdatePostParams, Result == Post {
}

struct AddPostUseCase: AddPostUseCaseProtocol {
    private let postRepository: PostRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let log = Logger.of("SavePostUseCase")
    
    init(postRepository: PostRepositoryProtocol, authService: AuthServiceProtocol) {
        self.postRepository = postRepository
        self.authService = authService
    }
    
    func execute(command: UpdatePostParams) async throws -> Post {
        do {
            if let myUserId = try await authService.getCurrentUser()?.id {
                let parmas = UpdatePostParams(
                    content: command.content,
                    createdAt: Date(),
                    updatedAt: Date(),
                    profileId: myUserId,
                    questionId: command.questionId,
                    isDeleted: command.isDeleted,
                    isHidden: command.isHidden
                )
                return try await postRepository.insert(params: parmas)
            } else {
                log.error("session expired...")
                throw DomainError.invalidSession("userId를 얻지 못했습니다.")
            }
        } catch {
            log.error("postRepository error. \(error)")
            throw DomainError.dataLayerError(error.localizedDescription)
        }
    }
}
