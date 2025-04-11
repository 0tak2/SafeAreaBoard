//
//  SignInWithIdTokenUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/10/25.
//

import Foundation
import Supabase

protocol GetAuthStateChangeAsyncStreamUseCaseProtocol {
    func execute() async -> AsyncStream<(event: Auth.AuthChangeEvent, session: Optional<Auth.Session>)>
}

struct GetAuthStateChangeAsyncStreamUseCase: GetAuthStateChangeAsyncStreamUseCaseProtocol {
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func execute() async -> AsyncStream<(event: Auth.AuthChangeEvent, session: Optional<Auth.Session>)> {
        await authService.getAuthStateChanges()
    }
}
