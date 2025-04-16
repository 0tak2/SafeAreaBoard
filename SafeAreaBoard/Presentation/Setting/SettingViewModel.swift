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
    
    private let getUserProfileUseCase: any GetCurrentUserProfileUseCaseProtocol
    private let updateFCMTokenUseCase: any UpdateFCMTokenUseCaseProtocol
    private let userDefaultRepository: any UserDefaultsRepositoryProtocol
    
    private var subscriptions: Set<AnyCancellable> = []
    private let log = Logger.of("SettingViewModel")
    
    init(
        getUserProfileUseCase: any GetCurrentUserProfileUseCaseProtocol,
        updateFCMTokenUseCase: any UpdateFCMTokenUseCaseProtocol,
        userDefaultRepository: any UserDefaultsRepositoryProtocol
    ) {
        self.getUserProfileUseCase = getUserProfileUseCase
        self.updateFCMTokenUseCase = updateFCMTokenUseCase
        self.userDefaultRepository = userDefaultRepository
    }
    
    func startTask() async {
        do {
            // MARK: get profile
            let profile = try await getUserProfileUseCase.execute(command: ())
            
            // MARK: load user notification status
            let userNotificationCenter = UNUserNotificationCenter.current()
            
            await MainActor.run {
                editingUserName = profile.nickname ?? ""
                isOnNotification = userDefaultRepository.get(key: .onRemoteNotification) ?? true
            }
            
            // MARK: register $isOnNotification sink
            // init이 아니라 값 로드 후 sink를 정의해야 뷰 로드마다 초기화되는 것을 막을 수 있다
            $isOnNotification.sink { isOnNotification in
                self.handleNotificationPreferenceChange()
            }
            .store(in: &subscriptions)
        } catch {
            log.error("failed to fetch user profile: \(error)")
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
}
