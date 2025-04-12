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
    }
}
