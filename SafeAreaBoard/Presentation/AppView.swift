//
//  ContentView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/9/25.
//

import SwiftUI
import AuthenticationServices

struct AppView: View {
    @StateObject private var viewModel: AppViewModel
    @EnvironmentObject private var container: DIContainerEnvironment
    
    init(viewModel: AppViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Group {
                if !viewModel.isSignedIn {
                    IntroPageView(viewModel: viewModel)
                } else {
                    if viewModel.isSignedIn && viewModel.nicknameSettingNeeded {
                        SetPreferenceView(viewModel: viewModel)
                    } else {
                        let boardViewModel = container.resolve(BoardViewModel.self)! // FIXME: should think about the way of injecting
                        let settingViewModel = container.resolve(MyViewModel.self)!
                        
                        MainTabView(
                            boardViewModel: boardViewModel,
                            settingViewModel: settingViewModel
                        )
                    }
                }
            }
            
            if viewModel.isError {
                ErrorView(errorMessage: "로그인 중 에러가 발생했습니다.")
            }
        }
        .task {
            Task {
                await viewModel.handleAuthStateChange()
            }
        }
    }
}

#Preview {
    let authService = AuthService(supabaseClient: SupabaseProvider.shared.supabase)
    let profileRepository = ProfileRepository(supabaseClient: SupabaseProvider.shared.supabase)
    
    AppView(
        viewModel: AppViewModel(getAuthStateChangeAsnycStreamUseCase: GetAuthStateChangeAsyncStreamUseCase(authService: authService), getCurrentUserProfileUseCase: GetCurrentUserProfileUseCase(authService: authService, profileRepository: profileRepository), signInWithIdTokenUseCase: SignInWithIdTokenUseCase(authService: authService), updateNicknameUseCase: UpdateNicknameUseCase(profileRepository: profileRepository))
    )
}
