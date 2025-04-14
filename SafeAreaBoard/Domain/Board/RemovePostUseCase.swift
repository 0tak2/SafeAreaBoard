//
//  SavePostUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/13/25.
//

import Foundation
import Supabase
import os.log

protocol RemovePostUseCaseProtocol: UseCase where Command == Int, Result == Void {
}

struct RemovePostUseCase: RemovePostUseCaseProtocol {
    private let postRepository: PostRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let log = Logger.of("UpdatePostUseCase")
    
    init(postRepository: PostRepositoryProtocol, authService: AuthServiceProtocol) {
        self.postRepository = postRepository
        self.authService = authService
    }
    
    /**
     command:   삭제할 포스트의 id
     */
    func execute(command: Int) async throws {
        do {
            try await postRepository.delete(postId: command)
        } catch {
            log.error("postRepository error. \(error)")
            throw DomainError.dataLayerError(error.localizedDescription)
        }
    }
}
