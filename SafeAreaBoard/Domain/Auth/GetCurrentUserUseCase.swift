//
//  SignInWithIdTokenUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/10/25.
//

import Foundation
import Supabase
import os.log

protocol GetCurrentUserUseCaseProtocol: UseCase where Command == Void, Result == User? {
}

struct GetCurrentUserUseCase: GetCurrentUserUseCaseProtocol {
    private let authService: AuthServiceProtocol
    private let log = Logger.of("GetCurrentUserUseCase")
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func execute(command: ()) async throws -> Auth.User? {
        do {
            return try await authService.getCurrentUser()
        } catch {
            log.error("authService error. \(error.localizedDescription)")
            throw DomainError.dataLayerError(error.localizedDescription)
        }
    }
}
