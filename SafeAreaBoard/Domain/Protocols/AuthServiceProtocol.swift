//
//  AuthServiceProtocol.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/10/25.
//

import Foundation
import Supabase

protocol AuthServiceProtocol {
    func signInWithIdToken(provider: OpenIDConnectCredentials.Provider, idToken: String) async throws
    func getAuthStateChanges() -> AsyncStream<(event: AuthChangeEvent, session: Session?)>
    func getCurrentUser() async throws -> User?
    func logout() async throws
}
