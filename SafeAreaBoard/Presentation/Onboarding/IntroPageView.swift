//
//  IntroPageView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/11/25.
//

import SwiftUI
import AuthenticationServices

struct IntroPageView: View {
    @ObservedObject private var viewModel: AppViewModel
    
#if DEBUG
    @State private var showingEmailLoginForm = false
#endif
    
    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 36)
            
            OnboardingHeaderView(title: "academy\n  .safeAreaBoard")
            
            VStack(alignment: .leading, spacing: 24) {
                ForEach(introTexts, id: \.self) { text in
                    Text("\(text)")
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(48)
            
            
            SignInWithAppleButton { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                viewModel.signInComplete(result: result)
            }
            .fixedSize()
        }
        
#if DEBUG
        .sheet(isPresented: $showingEmailLoginForm, content: {
            EmailLoginFormView()
        })
        .onShakeGesture {
            showingEmailLoginForm = true
        }
#endif
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    private let introTexts: [String] = [
        "1. 공통 질문에 대한 러너 서로의 경험을 공유해요",
        "2. 나의 경험을 공유할수록, 다른 사람의 경험에 공감할수록 아카데미 내의 심리적 안전감이 높아져요",
        "3. SafeAreaBoard에서 높은 심리적 안전감을 체감하고 아카데미의 심리적 안전감을 높이는데 기여하세요!",
    ]
}

#Preview {
    let authService = AuthService(supabaseClient: SupabaseProvider.shared.supabase)
    let profileRepository = ProfileRepository(supabaseClient: SupabaseProvider.shared.supabase)
    
    IntroPageView(viewModel: AppViewModel(
        getAuthStateChangeAsnycStreamUseCase: GetAuthStateChangeAsyncStreamUseCase(authService: authService),
        getCurrentUserProfileUseCase: GetProfileUseCase(authService: authService, profileRepository: profileRepository),
        signInWithIdTokenUseCase: SignInWithIdTokenUseCase(authService: authService),
        updateProfileUseCase: UpdateProfileUseCase(profileRepository: profileRepository))
    )
}
