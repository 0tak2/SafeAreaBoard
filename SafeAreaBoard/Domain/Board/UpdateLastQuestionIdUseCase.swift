//
//  UpdateLastQuestionIdUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/13/25.
//

import Foundation
import os.log

protocol UpdateLastQuestionIdUseCaseProtocol: UseCase where Command == Int, Result == Void {
}

struct UpdateLastQuestionIdUseCase: UpdateLastQuestionIdUseCaseProtocol {
    private let userDefaultsRepository: UserDefaultsRepositoryProtocol
    private let log = Logger.of("UpdateLastQuestionIdUseCase")
    
    init(userDefaultsRepository: UserDefaultsRepositoryProtocol) {
        self.userDefaultsRepository = userDefaultsRepository
    }
    
    /**
     command:   업데이트할 질문의  id
     */
    func execute(command: Int) async throws {
        userDefaultsRepository.set(command, forKey: .lastSelectedQuestionId)
    }
}
