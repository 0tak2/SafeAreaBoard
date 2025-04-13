//
//  GetAllQuestionsUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation
import Supabase
import os.log

protocol GetAllQuestionsUseCaseProtocol: UseCase where Command == Void, Result == [QuestionWithAnswerStatus] {
}

struct GetAllQuestionsUseCase: GetAllQuestionsUseCaseProtocol {
    private let questionRepository: QuestionRepositoryProtocol
    private let postRespository: PostRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let log = Logger.of("GetAllQuestionsUseCase")
    
    init(questionRepository: QuestionRepositoryProtocol, postRespository: PostRepositoryProtocol, authService: AuthServiceProtocol) {
        self.questionRepository = questionRepository
        self.postRespository = postRespository
        self.authService = authService
    }
    
    func execute(command: ()) async throws -> [QuestionWithAnswerStatus] {
        do {
            let questions = try await questionRepository.getAll()
            
            if let myUserId = try await authService.getCurrentUser()?.id {
                var result: [QuestionWithAnswerStatus] = []
                for question in questions {
                    if let _ = try await postRespository.getOne(questionId: question.questionId ?? 0, profileId: myUserId) {
                        result.append(QuestionWithAnswerStatus(question: question, didAnswer: true))
                    } else {
                        result.append(QuestionWithAnswerStatus(question: question, didAnswer: false))
                    }
                }
                return result
            } else {
                log.warning("session expired...")
                return questions.map { QuestionWithAnswerStatus(question: $0, didAnswer: false) }
            }
        } catch {
            log.error("questionRepository error. \(error)")
            throw DomainError.dataLayerError(error.localizedDescription)
        }
    }
}
