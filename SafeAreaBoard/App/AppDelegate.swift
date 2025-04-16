//
//  AppDelegate.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/16/25.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import os.log

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private let gcmMessageIDKey = "gcm.message_id"
    private let log = Logger.of("AppDelegate")
    private let updateFCMTokenUseCase: any UpdateFCMTokenUseCaseProtocol
    private let userDefaultRepository: any UserDefaultsRepositoryProtocol
    private var isRemoteNotficationEnabled: Bool {
        let isRemoteNotficationEnabled: Bool? = userDefaultRepository.get(key: .onRemoteNotification)
        return isRemoteNotficationEnabled ?? true // default value: true
    }
    
    override init() {
        let container = DIContainerProvider.shared.container
        self.updateFCMTokenUseCase = container.resolve((any UpdateFCMTokenUseCaseProtocol).self)!
        self.userDefaultRepository = container.resolve((any UserDefaultsRepositoryProtocol).self)!
        
        super.init()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // MARK: Firebase
        FirebaseApp.configure()
        log.info("Firebase initialized")
        
        // MARK: FCM
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        // FIXME: Should extract to UseCase?
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        if isRemoteNotficationEnabled {
            application.registerForRemoteNotifications()
        } else {
            application.unregisterForRemoteNotifications()
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        log.info("didRegisterForRemoteNotificationsWithDeviceToken deviceToken=\(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        log.info("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        
        if let fcmToken = fcmToken {
            Task {
                do {
                    try await updateFCMTokenUseCase.execute(command: fcmToken)
                    log.info("updateFCMTokenUseCase success fcmToken=\(fcmToken)")
                } catch {
                    log.error("update fcm token error: \(error)")
                }
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            log.info("message received when app is foreground. id=\(String(describing: messageID))")
        }
        
        log.debug("push userInfo: \(userInfo)")
        
        return [[.banner, .badge, .sound]]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            log.info("message received. id=\(String(describing: messageID))")
        }
        
        log.debug("push userInfo: \(userInfo)")
    }
}
