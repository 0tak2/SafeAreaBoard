//
//  AuthService.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/10/25.
//

import Foundation
import Supabase

final class AuthService: AuthServiceProtocol {
    private let supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    func signInWithIdToken(provider: OpenIDConnectCredentials.Provider, idToken: String) async throws {
        try await supabaseClient.auth.signInWithIdToken(credentials: .init(provider: provider, idToken: idToken))
    }
    
    func getAuthStateChanges() -> AsyncStream<(event: AuthChangeEvent, session: Session?)> {
        return supabaseClient.auth.authStateChanges
    }
    
    func getCurrentUser() async throws -> Auth.User? {
        return try await supabaseClient.auth.session.user
    }
    
    func logout() async throws {
        try await supabaseClient.auth.signOut()
    }
}
