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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // MARK: Firebase
        FirebaseApp.configure()
        log.info("Firebase initialized")
        
        // MARK: FCM
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
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
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
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
