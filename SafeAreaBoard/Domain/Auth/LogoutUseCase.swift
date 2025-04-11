//
//  SignInWithIdTokenUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/10/25.
//

import Foundation
import AuthenticationServices

protocol LogoutUseCaseProtocol: UseCase where Command == Void, Result == Void {
}

struct LogoutUseCase: LogoutUseCaseProtocol {
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func execute(command: ()) async throws -> () {
        do {
            try await authService.logout()
        } catch {
            throw DomainError.dataLayerError("\(error)")
        }
    }
}
