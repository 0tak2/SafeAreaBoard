//
//  DIContainer.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/11/25.
//

import Foundation
import Swinject
import os.log

final class DIContainerProvider {
    static let shared: DIContainerProvider = .init(container: Container())
    
    let container: Swinject.Container
    private let log = Logger.of("DIContainer")
    
    init(container: Swinject.Container) {
        self.container = container
        registerDataLayer()
        registerDomainLayer()
        registerPresentationLayer()
    }
    
    private func registerDataLayer() {
        container.register(AuthServiceProtocol.self) { _ in AuthService(supabaseClient: SupabaseProvider.shared.supabase)}
            .inObjectScope(.container)
        
        container.register(ProfileRepositoryProtocol.self) { _ in ProfileRepository(supabaseClient: SupabaseProvider.shared.supabase)}
            .inObjectScope(.container)
        
        container.register(QuestionRepositoryProtocol.self) { _ in QuestionRepository(supabaseClient: SupabaseProvider.shared.supabase)}
            .inObjectScope(.container)
        
        container.register(PostRepositoryProtocol.self) { _ in PostRepository(supabaseClient: SupabaseProvider.shared.supabase)}
            .inObjectScope(.container)
        
        container.register(ReactionRepositoryProtocol.self) { _ in ReactionRepository(supabaseClient: SupabaseProvider.shared.supabase)}
            .inObjectScope(.container)
        
        container.register(UserDefaultsRepositoryProtocol.self) { _ in UserDefaultsRepository() }
            .inObjectScope(.container)
    }
    
    private func registerDomainLayer() {
        container.register((any SignInWithIdTokenUseCaseProtocol).self) { r in
            guard let authService = r.resolve(AuthServiceProtocol.self) else {
                fatalError("AuthService not resolved")
            }
            return SignInWithIdTokenUseCase(authService: authService)
        }
        
        container.register((any GetCurrentUserUseCaseProtocol).self) { r in
            guard let authService = r.resolve(AuthServiceProtocol.self) else {
                fatalError("AuthService not resolved")
            }
            return GetCurrentUserUseCase(authService: authService)
        }
        
        container.register(GetAuthStateChangeAsyncStreamUseCaseProtocol.self) { r in
            guard let authService = r.resolve(AuthServiceProtocol.self) else {
                fatalError("AuthService not resolved")
            }
            return GetAuthStateChangeAsyncStreamUseCase(authService: authService)
        }
        
        container.register((any GetCurrentUserProfileUseCaseProtocol).self) { r in
            guard let authService = r.resolve(AuthServiceProtocol.self) else {
                fatalError("AuthService not resolved")
            }
            
            guard let profileRepository = r.resolve(ProfileRepositoryProtocol.self) else {
                fatalError("ProfileRepository not resolved")
            }
            
            return GetCurrentUserProfileUseCase(authService: authService, profileRepository: profileRepository)
        }
        
        container.register((any LogoutUseCaseProtocol).self) { r in
            guard let authService = r.resolve(AuthServiceProtocol.self) else {
                fatalError("AuthService not resolved")
            }
            
            return LogoutUseCase(authService: authService)
        }
        
        container.register((any UpdateNicknameUseCaseProtocol).self) { r in
            guard let profileRepository = r.resolve(ProfileRepositoryProtocol.self) else {
                fatalError("ProfileRepository not resolved")
            }
            
            return UpdateNicknameUseCase(profileRepository: profileRepository)
        }
        
        container.register((any UpdateFCMTokenUseCaseProtocol).self) { r in
            guard let profileRepository = r.resolve(ProfileRepositoryProtocol.self) else {
                fatalError("ProfileRepository not resolved")
            }
            
            guard let authService = r.resolve(AuthServiceProtocol.self) else {
                fatalError("AuthService not resolved")
            }
            
            return UpdateFCMTokenUseCase(profileRepository: profileRepository, authService: authService)
        }
        
        container.register((any GetAllQuestionsUseCaseProtocol).self) { r in
            guard let questionRepository = r.resolve(QuestionRepositoryProtocol.self) else {
                fatalError("QuestionRepository not resolved")
            }
            
            guard let postRepository = r.resolve(PostRepositoryProtocol.self) else {
                fatalError("ProfileRepository not resolved")
            }
            
            guard let authService = r.resolve(AuthServiceProtocol.self) else {
                fatalError("AuthService not resolved")
            }
            
            return GetAllQuestionsUseCase(
                questionRepository: questionRepository, postRespository: postRepository, authService: authService
            )
        }
        
        container.register((any GetAllPostsUseCaseProtocol).self) { r in
            guard let postRepository = r.resolve(PostRepositoryProtocol.self) else {
                fatalError("PostRepository not resolved")
            }
            
            guard let authService = r.resolve(AuthServiceProtocol.self) else {
                fatalError("AuthService not resolved")
            }
            
            return GetAllPostsUseCase(postRepository: postRepository, authService: authService)
        }
        
        container.register((any AddReactionUseCaseProtocol).self) { r in
            guard let reactionRepository = r.resolve(ReactionRepositoryProtocol.self) else {
                fatalError("ReactionRepository not resolved")
            }
            
            guard let authService = r.resolve(AuthServiceProtocol.self) else {
                fatalError("AuthService not resolved")
            }
            
            return AddReactionUseCase(reactionRepository: reactionRepository, authService: authService)
        }
        
        container.register((any RemoveReactionUseCaseProtocol).self) { r in
            guard let reactionRepository = r.resolve(ReactionRepositoryProtocol.self) else {
                fatalError("ReactionRepository not resolved")
            }
            
            guard let authService = r.resolve(AuthServiceProtocol.self) else {
                fatalError("AuthService not resolved")
            }
            
            return RemoveReactionUseCase(reactionRepository: reactionRepository, authService: authService)
        }
        
        container.register((any AddPostUseCaseProtocol).self) { r in
            guard let postRepository = r.resolve(PostRepositoryProtocol.self) else {
                fatalError("ReactionRepository not resolved")
            }
            
            guard let authService = r.resolve(AuthServiceProtocol.self) else {
                fatalError("AuthService not resolved")
            }
            
            return AddPostUseCase(postRepository: postRepository, authService: authService)
        }
        
        container.register((any GetMyPostUseCaseProtocol).self) { r in
            guard let postRepository = r.resolve(PostRepositoryProtocol.self) else {
                fatalError("ReactionRepository not resolved")
            }
            
            guard let authService = r.resolve(AuthServiceProtocol.self) else {
                fatalError("AuthService not resolved")
            }
            
            return GetMyPostUseCase(postRespository: postRepository, authService: authService)
        }
        
        container.register((any UpdateLastQuestionIdUseCaseProtocol).self) { r in
            guard let userDefaultsRepository = r.resolve(UserDefaultsRepositoryProtocol.self) else {
                fatalError("UserDefaultsRepository not resolved")
            }
            
            return UpdateLastQuestionIdUseCase(userDefaultsRepository: userDefaultsRepository)
        }
        
        container.register((any GetLastQuestionIdUseCaseProtocol).self) { r in
            guard let userDefaultsRepository = r.resolve(UserDefaultsRepositoryProtocol.self) else {
                fatalError("UserDefaultsRepository not resolved")
            }
            
            return GetLastQuestionIdUseCase(userDefaultsRepository: userDefaultsRepository)
        }
        
        container.register((any UpdatePostUseCaseProtocol).self) { r in
            guard let postRepository = r.resolve(PostRepositoryProtocol.self) else {
                fatalError("ReactionRepository not resolved")
            }
            
            guard let authService = r.resolve(AuthServiceProtocol.self) else {
                fatalError("AuthService not resolved")
            }
            
            return UpdatePostUseCase(postRepository: postRepository, authService: authService)
        }
        
        container.register((any RemovePostUseCaseProtocol).self) { r in
            guard let postRepository = r.resolve(PostRepositoryProtocol.self) else {
                fatalError("ReactionRepository not resolved")
            }
            
            guard let authService = r.resolve(AuthServiceProtocol.self) else {
                fatalError("AuthService not resolved")
            }
            
            return RemovePostUseCase(postRepository: postRepository, authService: authService)
        }
        
        container.register((any GetAllMyPostsUseCaseProtocol).self) { r in
            guard let postRepository = r.resolve(PostRepositoryProtocol.self) else {
                fatalError("ReactionRepository not resolved")
            }
            
            guard let authService = r.resolve(AuthServiceProtocol.self) else {
                fatalError("AuthService not resolved")
            }
            
            return GetAllMyPostsUseCase(postRespository: postRepository, authService: authService)
        }
    }
    
    private func registerPresentationLayer() {
        container.register(AppViewModel.self) { r in
            guard let getAuthStateChangeAsnycStreamUseCase = r.resolve(GetAuthStateChangeAsyncStreamUseCaseProtocol.self) else {
                fatalError("GetAuthStateChangeAsnycStreamUseCase not resolved")
            }
            
            guard let getCurrentUserProfileUseCase = r.resolve((any GetCurrentUserProfileUseCaseProtocol).self) else {
                fatalError("GetAuthStateChangeAsnycStreamUseCase not resolved")
            }
            
            guard let signInWithIdTokenUseCase = r.resolve((any SignInWithIdTokenUseCaseProtocol).self) else {
                fatalError("SignInWithIdTokenUseCase not resolved")
            }
            
            guard let updateNicknameUseCase = r.resolve((any UpdateNicknameUseCaseProtocol).self) else {
                fatalError("SignInWithIdTokenUseCase not resolved")
            }
            
            return AppViewModel(
                getAuthStateChangeAsnycStreamUseCase: getAuthStateChangeAsnycStreamUseCase,
                getCurrentUserProfileUseCase: getCurrentUserProfileUseCase,
                signInWithIdTokenUseCase: signInWithIdTokenUseCase,
                updateNicknameUseCase: updateNicknameUseCase
            )
        }
        
        container.register(TabRouter.self) { _ in
            TabRouter()
        }
        
        container.register(BoardViewModel.self) { r in
            guard let getAllQuestionsUseCase = r.resolve((any GetAllQuestionsUseCaseProtocol).self) else {
                fatalError("GetAllQuestionsUseCase not resolved")
            }
            
            guard let getAllPostsUseCase = r.resolve((any GetAllPostsUseCaseProtocol).self) else {
                fatalError("GetAllPostsUseCase not resolved")
            }
            
            guard let addReactionUseCase = r.resolve((any AddReactionUseCaseProtocol).self) else {
                fatalError("AddReactionUseCase not resolved")
            }
            
            guard let removeReactionUseCase = r.resolve((any RemoveReactionUseCaseProtocol).self) else {
                fatalError("RemoveReactionUseCase not resolved")
            }
            
            guard let removePostUseCase = r.resolve((any RemovePostUseCaseProtocol).self) else {
                fatalError("RemovePostUseCase not resolved")
            }
            
            return BoardViewModel(
                getAllQuestionsUseCase: getAllQuestionsUseCase,
                getAllPostsUseCase: getAllPostsUseCase,
                addReactionUseCase: addReactionUseCase,
                removeReactionUseCase: removeReactionUseCase,
                removePostUseCase: removePostUseCase
            )
        }
        
        container.register(WriteViewModel.self) { r in
            guard let addPostUseCase = r.resolve((any AddPostUseCaseProtocol).self) else {
                fatalError("addPostUseCase not resolved")
            }
            
            guard let updatePostUseCase = r.resolve((any UpdatePostUseCaseProtocol).self) else {
                fatalError("addPostUseCase not resolved")
            }
            
            return WriteViewModel(
                addPostUseCase: addPostUseCase,
                updatePostUseCase: updatePostUseCase
            )
        }
        
        container.register(MyViewModel.self) { r in
            guard let getUserProfileUseCase = r.resolve((any GetCurrentUserProfileUseCaseProtocol).self) else {
                fatalError("GetCurrentUserProfileUseCase not resolved")
            }
            
            guard let updateNicknameUseCase = r.resolve((any UpdateNicknameUseCaseProtocol).self) else {
                fatalError("UpdateNicknameUseCase not resolved")
            }
            
            guard let updateFCMTokenUseCase = r.resolve((any UpdateFCMTokenUseCaseProtocol).self) else {
                fatalError("UpdateFCMTokenUseCase not resolved")
            }
            
            guard let logoutUseCase = r.resolve((any LogoutUseCaseProtocol).self) else {
                fatalError("LogoutUseCase not resolved")
            }
            
            guard let userDefaultsRepository = r.resolve(UserDefaultsRepositoryProtocol.self) else {
                fatalError("UserDefaultsRepository not resolved")
            }
            
            return MyViewModel(
                getUserProfileUseCase: getUserProfileUseCase,
                updateNicknameUseCase: updateNicknameUseCase,
                updateFCMTokenUseCase: updateFCMTokenUseCase,
                logoutUseCase: logoutUseCase,
                userDefaultRepository: userDefaultsRepository
            )
        }
        
        container.register(MyPostsViewModel.self) { r in
            guard let getAllMyPostsUseCase = r.resolve((any GetAllMyPostsUseCaseProtocol).self) else {
                fatalError("GetAllMyPostsUseCase not resolved")
            }
            
            guard let removePostUseCase = r.resolve((any RemovePostUseCaseProtocol).self) else {
                fatalError("RemovePostUseCase not resolved")
            }
            
            guard let addReactionUseCase = r.resolve((any AddReactionUseCaseProtocol).self) else {
                fatalError("AddReactionUseCase not resolved")
            }
            
            guard let removeReactionUseCase = r.resolve((any RemoveReactionUseCaseProtocol).self) else {
                fatalError("RemoveReactionUseCase not resolved")
            }
            
            return MyPostsViewModel(
                getAllMyPostsUseCase: getAllMyPostsUseCase,
                removePostUseCase: removePostUseCase,
                addReactionUseCase: addReactionUseCase,
                removeReactionUseCase: removeReactionUseCase
            )
        }
    }
}
