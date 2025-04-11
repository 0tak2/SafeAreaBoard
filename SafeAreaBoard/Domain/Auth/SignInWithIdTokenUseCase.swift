//
//  SignInWithIdTokenUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/10/25.
//

import Foundation
import AuthenticationServices
import os.log

protocol SignInWithIdTokenUseCaseProtocol: UseCase where Command == ASAuthorization, Result == Void {
}

struct SignInWithIdTokenUseCase: SignInWithIdTokenUseCaseProtocol {
    private let authService: AuthServiceProtocol
    private let log = Logger.of("SignInWithIdTokenUseCase")
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func execute(command: ASAuthorization) throws -> () {
        Task {
            guard let credential = command.credential as? ASAuthorizationAppleIDCredential else {
                return
            }
            
            guard let idToken = credential.identityToken
                .flatMap({ String(data: $0, encoding: .utf8) }) else {
                return
            }
            
            do {
                try await authService.signInWithIdToken(provider: .apple, idToken: idToken)
            } catch {
                log.error("Data Layer Error: \(error.localizedDescription)")
                throw DomainError.dataLayerError(error.localizedDescription)
            }
        }
    }
}
