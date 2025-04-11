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
                Text("academy\n  .safeAreaBoard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(CustomColors.primaryDarker1)
            }
            
            VStack(alignment: .leading) {
                ForEach(introTexts, id: \.self) { text in
                    Text(text)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
                
                SignInWithAppleButton { request in
                    request.requestedScopes = [.email, .fullName]
                } onCompletion: { result in
                    viewModel.signInComplete(result: result)
                }
                .fixedSize()
            }
        }
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
