//
//  SettingView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import SwiftUI

struct SettingView: View {
    @StateObject private var viewModel: SettingViewModel
    @FocusState var textFieldFocused: Bool
    
    init(viewModel: SettingViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 48) {
                        Text("닉네임")
                        TextField("", text: $viewModel.editingUserName)
                            .focused($textFieldFocused)
                    }
                    
                    Toggle("알림 수신", isOn: $viewModel.isOnNotification)
                }
                
                Section {
                    Button {
                        //
                    } label: {
                        Text("로그아웃")
                            .foregroundStyle(CustomColors.primaryDarker2)
                    }
                }
            }
            .listStyle(.grouped)
            .onTapGesture {
                textFieldFocused = false
            }
            .alert("저장되었습니다.", isPresented: $viewModel.showingCompleteAlert) { }
            .navigationTitle("설정")
            .toolbar {
                Button("저장") {
                    viewModel.saveButtonTapped()
                    textFieldFocused = false
                }
                .disabled(!viewModel.saveButtonEnabled)
                .tint(CustomColors.primaryDarker2)
            }
        }
        .task {
            await viewModel.startTask()
        }
    }
}

#Preview {
    let authService = AuthService(supabaseClient: SupabaseProvider.shared.supabase)
    let profileRepository = ProfileRepository(supabaseClient: SupabaseProvider.shared.supabase)
    
    SettingView(viewModel: SettingViewModel(
        getUserProfileUseCase: GetCurrentUserProfileUseCase(
            authService: authService,
            profileRepository: profileRepository
        ),
        updateNicknameUseCase: UpdateNicknameUseCase(profileRepository: profileRepository),
        updateFCMTokenUseCase: UpdateFCMTokenUseCase(
            profileRepository: profileRepository,
            authService: authService
        ),
        logoutUseCase: LogoutUseCase(authService: authService),
        userDefaultRepository: UserDefaultsRepository()
    ))
}
