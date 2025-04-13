//
//  GetAllQuestionsUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation
import Supabase
import os.log

protocol GetAllQuestionsUseCaseProtocol: UseCase where Command == Void, Result == [Question] {
}

struct GetAllQuestionsUseCase: GetAllQuestionsUseCaseProtocol {
    private let questionRepository: QuestionRepositoryProtocol
    private let log = Logger.of("GetAllQuestionsUseCase")
    
    init(questionRepository: QuestionRepositoryProtocol) {
        self.questionRepository = questionRepository
    }
    
    func execute(command: ()) async throws -> [Question] {
        do {
            return try await questionRepository.getAll()
        } catch {
            log.error("questionRepository error. \(error.localizedDescription)")
            throw DomainError.dataLayerError(error.localizedDescription)
        }
    }
}
