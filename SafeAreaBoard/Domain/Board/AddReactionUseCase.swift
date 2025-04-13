//
//  GetAllQuestionsUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation
import Supabase
import os.log

protocol AddReactionUseCaseProtocol: UseCase where Command == Int, Result == Void {
}

struct AddReactionUseCase: AddReactionUseCaseProtocol {
    private let reactionRepository: ReactionRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let log = Logger.of("AddReactionUseCase")
    private let reactionType: String = "heart"
    
    init(reactionRepository: ReactionRepositoryProtocol, authService: AuthServiceProtocol) {
        self.reactionRepository = reactionRepository
        self.authService = authService
    }
    
    /**
     command:   리액션할 포스트의 id
     */
    func execute(command: Int) async throws {
        do {
            guard let userId = try await authService.getCurrentUser()?.id else {
                log.warning("userId is nil")
                return
            }
            
            let _ = try await reactionRepository.insert(params: .init(type: reactionType, createdAt: Date(), profileId: userId, postId: command))
        } catch {
            log.error("data layer error. \(error)")
            throw DomainError.dataLayerError(error.localizedDescription)
        }
    }
}
