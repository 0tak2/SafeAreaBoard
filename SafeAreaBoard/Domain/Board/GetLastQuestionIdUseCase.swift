//
//  GetLastQuestionIdUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/13/25.
//

import Foundation
import os.log

protocol GetLastQuestionIdUseCaseProtocol: SyncUseCase where Command == Void, Result == Int? {
}

struct GetLastQuestionIdUseCase: GetLastQuestionIdUseCaseProtocol {
    private let userDefaultsRepository: UserDefaultsRepositoryProtocol
    private let log = Logger.of("GetLastQuestionIdUseCase")
    
    init(userDefaultsRepository: UserDefaultsRepositoryProtocol) {
        self.userDefaultsRepository = userDefaultsRepository
    }
    
    /**
     command:   업데이트할 질문의  id
     */
    func execute(command: ()) throws -> Int? {
        return userDefaultsRepository.get(key: .lastSelectedQuestionId)
    }
}
