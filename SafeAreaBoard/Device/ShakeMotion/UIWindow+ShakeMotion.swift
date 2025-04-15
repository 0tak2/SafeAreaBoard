//
//  UIWindow+ShakeMotion.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/15/25.
//

import Foundation
import UIKit

let deviceDidShakeNotification = NSNotification.Name("ShakeMotion")

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: NSNotification.Name("ShakeMotion"), object: nil)
        }
    }
}
