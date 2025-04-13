//
//  Date+Helpers.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation

extension Date {
    var relativeLocalizedDescription: String {
        let currentTimeStamp = Date().timeIntervalSince1970
        let selfTimeStamp = self.timeIntervalSince1970
        let timeInterval = Int(floor(currentTimeStamp - selfTimeStamp))
        
        if timeInterval < 5 {
            return "방금"
        }
        
        if timeInterval < 60 {
            return "\(timeInterval)초 전"
        }
        
        if timeInterval < 60 * 60 {
            return "\(timeInterval / 60)분 전"
        }
        
        if timeInterval < 60 * 60 * 60,
           timeInterval / 60 / 60 < 24 {
            return "\(timeInterval / 60 / 60)시간 전"
        }
        
        return self.localizedDescription
    }
    
    var localizedDescription: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 HH:mm"

        return formatter.string(from: self)
    }
}
