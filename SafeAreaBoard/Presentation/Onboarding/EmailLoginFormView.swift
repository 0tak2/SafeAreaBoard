//
//  EmailLoginFormView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/15/25.
//

import SwiftUI

/**
 For debug/testing
 */
struct EmailLoginFormView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    private let authService: AuthServiceProtocol = AuthService(supabaseClient: SupabaseProvider.shared.supabase)
    
    var body: some View {
        Form {
            TextField(text: $email) {
                Text("개발 계정 이메일")
            }
            .textInputAutocapitalization(.never)
            
            SecureField(text: $password) {
                Text("개발 계정 비밀번호")
            }
            
            Section {
                Button {
                    loginButtonTapped()
                } label: {
                    Text("로그인")
                }
            }

        }
    }
    
    func loginButtonTapped() {
        Task {
            do {
                try await authService.signInWithEmail(email: email, password: password)
                
                // MARK: Remote Notification
                // FIXME: Duplicated
                let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
                await UIApplication.shared.registerForRemoteNotifications()
            } catch {
                print("로그인에 실패했습니다. \(error)")
            }
        }
    }
}
