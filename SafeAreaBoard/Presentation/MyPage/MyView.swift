//
//  SettingView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import SwiftUI

struct MyView: View {
    @StateObject private var viewModel: MyViewModel
    @StateObject private var navigationRouter = NavigationRouter()
    @FocusState var textFieldFocused: Bool
    @State private var showingMyPosts: Bool = false
    @EnvironmentObject private var container: DIContainerEnvironment
    
    init(viewModel: MyViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack(path: $navigationRouter.paths) {
            List {
                Section {
                    HStack(spacing: 48) {
                        Text("닉네임")
                        TextField("", text: $viewModel.editingUserName)
                            .focused($textFieldFocused)
                            .toolbar {
                                ToolbarItem(placement: .keyboard) {
                                    HStack {
                                        Spacer()
                                        Button("완료") {
                                            textFieldFocused = false
                                        }
                                    }
                                }
                            }
                    }
                }
                
                Section {
                    NavigationLink(value: NavigationRouter.Path.myPosts) {
                        Text("내가 공유한 경험")
                            .foregroundStyle(CustomColors.primaryDarker2)
                    }
                }
                
                Spacer()
                
                Section {
                    Toggle("알림 수신", isOn: $viewModel.isOnNotification)
                    Text("로그아웃")
                        .foregroundStyle(CustomColors.primaryDarker2)
                        .onTapGesture {
                            viewModel.logoutButtonTapped()
                        }
                }
            }
            .listStyle(.plain)
            .alert("저장되었습니다.", isPresented: $viewModel.showingCompleteAlert) { }
            .navigationTitle("마이")
            .navigationDestination(for: NavigationRouter.Path.self) { path in
                switch path {
                case .edit(let question, let postOrNil):
                    WriteView(viewModel: resolveWirteViewModel(question: question, post: postOrNil))
                case .myPosts:
                    let myPostsViewModel = container.resolve(MyPostsViewModel.self)!
                    MyPostsView(viewModel: myPostsViewModel, navigationRouter: navigationRouter)
                }
            }
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
    
    func resolveWirteViewModel(question: Question, post: Post?) -> WriteViewModel {
        let wrtieViewModel = container.resolve(WriteViewModel.self)!
        wrtieViewModel.navigationRouter = navigationRouter
        
        if let post = post {
            wrtieViewModel.configure(isEditMode: true, question: question, post: post)
        } else {
            wrtieViewModel.configure(isEditMode: false, question: question, post: nil)
        }
        
        return wrtieViewModel
    }
}

#Preview {
    let authService = AuthService(supabaseClient: SupabaseProvider.shared.supabase)
    let profileRepository = ProfileRepository(supabaseClient: SupabaseProvider.shared.supabase)
    
    MyView(viewModel: MyViewModel(
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
