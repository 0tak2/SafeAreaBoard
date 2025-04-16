//
//  SettingViewModel.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/16/25.
//

import Foundation
import Combine
import UserNotifications
import os.log
import SwiftUI

final class SettingViewModel: ObservableObject {
    @Published var isError = false
    @Published var editingUserName = ""
    @Published var isOnNotification: Bool = false
    @Published var saveButtonEnabled: Bool = true
    @Published var showingCompleteAlert: Bool = false
    
    private let getUserProfileUseCase: any GetCurrentUserProfileUseCaseProtocol
    private let updateNicknameUseCase: any UpdateNicknameUseCaseProtocol
    private let updateFCMTokenUseCase: any UpdateFCMTokenUseCaseProtocol
    private let userDefaultRepository: any UserDefaultsRepositoryProtocol
    private var currentUserProfile: Profile?
    
    private var subscriptions: Set<AnyCancellable> = []
    private let log = Logger.of("SettingViewModel")
    
    init(
        getUserProfileUseCase: any GetCurrentUserProfileUseCaseProtocol,
        updateNicknameUseCase: any UpdateNicknameUseCaseProtocol,
        updateFCMTokenUseCase: any UpdateFCMTokenUseCaseProtocol,
        userDefaultRepository: any UserDefaultsRepositoryProtocol
    ) {
        self.getUserProfileUseCase = getUserProfileUseCase
        self.updateNicknameUseCase = updateNicknameUseCase
        self.updateFCMTokenUseCase = updateFCMTokenUseCase
        self.userDefaultRepository = userDefaultRepository
    }
    
    func startTask() async {
        do {
            currentUserProfile = try await getUserProfileUseCase.execute(command: ())
            
            await MainActor.run {
                editingUserName = currentUserProfile?.nickname ?? ""
                isOnNotification = userDefaultRepository.get(key: .onRemoteNotification) ?? true
            }
            
            // MARK: register $isOnNotification sink
            // init이 아니라 값 로드 후 sink를 정의해야 뷰 로드마다 초기화되는 것을 막을 수 있다
            $isOnNotification.sink { isOnNotification in
                self.handleNotificationPreferenceChange()
            }
            .store(in: &subscriptions)
            
            $editingUserName
                .receive(on: RunLoop.main)
                .sink { userName in
                self.saveButtonEnabled = !userName.isEmpty
            }
            .store(in: &subscriptions)
        } catch {
            log.error("failed to fetch user preferences: \(error)")
            isError = true
        }
    }
    
    func handleNotificationPreferenceChange() {
        Task {
            let userNotificationCenter = UNUserNotificationCenter.current()
            
            if isOnNotification {
                // FIXME: Should extract to UseCase?
                do {
                    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                    try await userNotificationCenter.requestAuthorization(options: authOptions)
                    await UIApplication.shared.registerForRemoteNotifications()
                    userDefaultRepository.set(true, forKey: .onRemoteNotification) // for next app launching
                    log.info("notification enabled")
                } catch {
                    log.error("failed to request authorization error: \(error)")
                    isOnNotification = false
                }
                return
            }
            
            // 알림 비활성화
            await UIApplication.shared.unregisterForRemoteNotifications()
            userDefaultRepository.set(false, forKey: .onRemoteNotification) // for next app launching
            log.info("notification disabled")
        }
    }
    
    func saveButtonTapped() {
        Task {
            await updateNickname()
        }
    }
    
    func updateNickname() async {
        guard let userId = currentUserProfile?.userId else {
            return
        }
        
        do {
            let _ = try await updateNicknameUseCase.execute(command: UpdateProfileCommand(userId: userId, params: UpdateProfileParams(nickname: editingUserName)))
            await MainActor.run {
                showingCompleteAlert = true
            }
        } catch {
            log.error("failed to udpate nickname")
            await MainActor.run {
                isError = true
            }
        }
    }
}
