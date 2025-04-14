//
//  GetMyQuestionUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/13/25.
//

import Foundation
import Supabase
import os.log

protocol GetMyPostUseCaseProtocol: UseCase where Command == Int, Result == Post? {
}

struct GetMyPostUseCase: GetMyPostUseCaseProtocol {
    private let postRespository: PostRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let log = Logger.of("GetMyQuestionUseCase")
    
    init(postRespository: PostRepositoryProtocol, authService: AuthServiceProtocol) {
        self.postRespository = postRespository
        self.authService = authService
    }
    
    /**
     command:   조회할 포스트가 속한 질문의 id
     */
    func execute(command: Int) async throws -> Post? {
        do {
            if let myUserId = try await authService.getCurrentUser()?.id {
                return try await postRespository.getOne(questionId: command, profileId: myUserId)
            } else {
                log.warning("session expired...")
                return nil
            }
        } catch {
            log.error("questionRepository error. \(error)")
            throw DomainError.dataLayerError(error.localizedDescription)
        }
    }
}
