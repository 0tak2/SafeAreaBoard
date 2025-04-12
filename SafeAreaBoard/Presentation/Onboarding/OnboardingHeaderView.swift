//
//  OnboardingHeaderView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import SwiftUI

struct OnboardingHeaderView: View {
    private let title: String
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        ZStack {
            Image("SafeArea")
                .frame(width: 351, height: 351)
            Text(title)
                .font(CustomFonts.onboradingTitle)
                .foregroundStyle(CustomColors.primaryDarker1)
        }
    }
}

#Preview {
    OnboardingHeaderView(title: "academy\n  .safeAreaBoard")
}
