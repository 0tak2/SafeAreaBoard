//
//  SignInViewModel.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/10/25.
//

import Foundation
import AuthenticationServices
import os.log

final class AppViewModel: ObservableObject {
    @Published var isSignedIn = false
    @Published var nicknameSettingNeeded = false
    @Published var editingNickname = ""
    @Published var isError = false
    @Published var isAlertShow = false
    
    private let getAuthStateChangeAsnycStreamUseCase: any GetAuthStateChangeAsyncStreamUseCaseProtocol
    private let getCurrentUserProfileUseCase: any GetCurrentUserProfileUseCaseProtocol
    private let signInWithIdTokenUseCase: any SignInWithIdTokenUseCaseProtocol
    private let updateNicknameUseCase: any UpdateNicknameUseCaseProtocol
    
    private var userId: UUID? // cannot bind to view
    
    private let log = Logger.of("AppViewModel")
    
    init(
        getAuthStateChangeAsnycStreamUseCase: any GetAuthStateChangeAsyncStreamUseCaseProtocol,
        getCurrentUserProfileUseCase: any GetCurrentUserProfileUseCaseProtocol,
        signInWithIdTokenUseCase: any SignInWithIdTokenUseCaseProtocol,
        updateNicknameUseCase: any UpdateNicknameUseCaseProtocol
    ) {
        self.getAuthStateChangeAsnycStreamUseCase = getAuthStateChangeAsnycStreamUseCase
        self.getCurrentUserProfileUseCase = getCurrentUserProfileUseCase
        self.signInWithIdTokenUseCase = signInWithIdTokenUseCase
        self.updateNicknameUseCase = updateNicknameUseCase
    }
  
    func handleAuthStateChange() async {
        for await state in await getAuthStateChangeAsnycStreamUseCase.execute() {
            log.info("auth state changed: \(state.event.rawValue)")
            
            if [.signedIn, .initialSession].contains(state.event) {
                guard let session = state.session else {
                    log.info("session is nil")
                    await MainActor.run {
                        isSignedIn = false
                        userId = nil
                    }
                    
                    continue
                }
                
                do {
                    let profile = try await getCurrentUserProfileUseCase.execute(command: ())
                    log.info("signedIn - userId=\(profile.userId?.uuidString ?? "N/A") nickname=\(profile.nickname ?? "N/A")")
                    if let nickname = profile.nickname,
                       !nickname.isEmpty {
                        await MainActor.run {
                            isSignedIn = true
                            nicknameSettingNeeded = false
                            userId = profile.userId
                        }
                    } else {
                        await MainActor.run {
                            isSignedIn = true
                            nicknameSettingNeeded = true
                            userId = profile.userId
                        }
                    }
                } catch {
                    log.error("getCurrentUserProfileUseCase failed: \(error)")
                }
            }
            
            if state.event == .signedOut {
                await MainActor.run {
                    isSignedIn = false
                    userId = nil
                }
            }
        }
    }
    
    func signInComplete(result: Result<ASAuthorization, any Error>) {
        do {
            let authorization = try result.get()
            Task {
                try await signInWithIdTokenUseCase.execute(command: authorization)
                
                // MARK: Remote Notification
                // FIXME: Duplicated
                let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
                await UIApplication.shared.registerForRemoteNotifications()
            }
        } catch {
            isError = true
        }
    }
    
    func continueButtonTapped() {
        guard let userId = userId else {
            return
        }
        
        guard !editingNickname.isEmpty else {
            isAlertShow = true
            return
        }
        
        Task {
            do {
                let _ = try await updateNicknameUseCase.execute(command: .init(userId: userId, params: .init(nickname: editingNickname)))
            } catch {
                log.error("updateNicknameUseCase failed: \(error)")
                isError = true
            }
            
            await MainActor.run {
                nicknameSettingNeeded = false
            }
        }
    }
}
