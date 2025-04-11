//
//  ErrorView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/11/25.
//

import SwiftUI

struct ErrorView: View {
    private let errorMessage: String
    
    init(errorMessage: String) {
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text(errorMessage)
                .foregroundStyle(Color.white)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .foregroundStyle(Color.red)
                )
            Spacer()
                .frame(height: 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorView(errorMessage: "에러가 발생했습니다.")
}
