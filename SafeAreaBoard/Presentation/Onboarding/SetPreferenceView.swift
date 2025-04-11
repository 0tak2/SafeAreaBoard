//
//  SignInView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/11/25.
//

import SwiftUI
import AuthenticationServices

struct SetPreferenceView: View {
    @ObservedObject private var viewModel: AppViewModel
    @FocusState private var isFocused: Bool
    
    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 36) {
            Spacer()
                .frame(height: 36)
            
            ZStack {
                Image("SafeArea")
                    .frame(width: 307, height: 307)
                Text("user\n  .preferences")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(CustomColors.primaryDarker1)
            }
            
            VStack(alignment: .leading) {
                HStack(spacing: 48) {
                    Text("닉네임")
                        .font(.body)
                    TextField("닉네임", text: $viewModel.editingNickname)
                        .focused($isFocused)
                }
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.gray)
            }
            
            Button("계속하기") {
                viewModel.continueButtonTapped()
            }
        }
        .onTapGesture {
            isFocused = false
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
