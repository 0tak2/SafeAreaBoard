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
            
            OnboardingHeaderView(title: "academy\n  .safeAreaBoard")
            
            VStack(alignment: .leading) {
                HStack(spacing: 48) {
                    Text("닉네임")
                        .font(.body)
                    TextField("Bob", text: $viewModel.editingNickname)
                        .focused($isFocused)
                }
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.gray)
            }
            .padding(16)
            
            Button("시작하기") {
                viewModel.continueButtonTapped()
            }
            .buttonStyle(ContinueButtonStyle())
        }
        .onTapGesture {
            isFocused = false
        }
        .alert(isPresented: $viewModel.isAlertShow) {
            Alert(title: Text("닉네임을 입력해 주세요"))
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

fileprivate struct ContinueButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, weight: .bold))
            .foregroundStyle(CustomColors.warmGrayDarker2)
            .padding(.init(top: 16, leading: 98, bottom: 16, trailing: 98))
            .background(CustomColors.warmGrayLigher1)
            .clipShape(.rect(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(CustomColors.warmGray, lineWidth: 1)
            )
    }
}
