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
        
        container.register((any GetProfileUseCaseProtocol).self) { r in
            guard let authService = r.resolve(AuthServiceProtocol.self) else {
                fatalError("AuthService not resolved")
            }
            
            guard let profileRepository = r.resolve(ProfileRepositoryProtocol.self) else {
                fatalError("ProfileRepository not resolved")
            }
            
            return GetProfileUseCase(authService: authService, profileRepository: profileRepository)
        }
        
        container.register((any LogoutUseCaseProtocol).self) { r in
            guard let authService = r.resolve(AuthServiceProtocol.self) else {
                fatalError("AuthService not resolved")
            }
            
            return LogoutUseCase(authService: authService)
        }
        
        container.register((any UpdateProfileUseCaseProtocol).self) { r in
            guard let profileRepository = r.resolve(ProfileRepositoryProtocol.self) else {
                fatalError("ProfileRepository not resolved")
            }
            
            return UpdateProfileUseCase(profileRepository: profileRepository)
        }
        
        container.register((any GetAllQuestionsUseCaseProtocol).self) { r in
            guard let questionRepository = r.resolve(QuestionRepositoryProtocol.self) else {
                fatalError("QuestionRepository not resolved")
            }
            
            return GetAllQuestionsUseCase(questionRepository: questionRepository)
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
    }
    
    private func registerPresentationLayer() {
        container.register(AppViewModel.self) { r in
            guard let getAuthStateChangeAsnycStreamUseCase = r.resolve(GetAuthStateChangeAsyncStreamUseCaseProtocol.self) else {
                fatalError("GetAuthStateChangeAsnycStreamUseCase not resolved")
            }
            
            guard let getCurrentUserProfileUseCase = r.resolve((any GetProfileUseCaseProtocol).self) else {
                fatalError("GetAuthStateChangeAsnycStreamUseCase not resolved")
            }
            
            guard let signInWithIdTokenUseCase = r.resolve((any SignInWithIdTokenUseCaseProtocol).self) else {
                fatalError("SignInWithIdTokenUseCase not resolved")
            }
            
            guard let updateProfileUseCase = r.resolve((any UpdateProfileUseCaseProtocol).self) else {
                fatalError("SignInWithIdTokenUseCase not resolved")
            }
            
            return AppViewModel(
                getAuthStateChangeAsnycStreamUseCase: getAuthStateChangeAsnycStreamUseCase,
                getCurrentUserProfileUseCase: getCurrentUserProfileUseCase,
                signInWithIdTokenUseCase: signInWithIdTokenUseCase,
                updateProfileUseCase: updateProfileUseCase
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
            
            return BoardViewModel(
                getAllQuestionsUseCase: getAllQuestionsUseCase,
                getAllPostsUseCase: getAllPostsUseCase,
                addReactionUseCase: addReactionUseCase,
                removeReactionUseCase: removeReactionUseCase
            )
        }
    }
}
