//
//  GetCurrentUserProfileUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/11/25.
//

import Foundation
import os.log

protocol GetCurrentUserProfileUseCaseProtocol: UseCase where Command == Void, Result == Profile {
}

struct GetCurrentUserProfileUseCase: GetCurrentUserProfileUseCaseProtocol {
    private let authService: AuthServiceProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private let log = Logger.of("GetCurrentUserProfileUseCase")
    
    init(authService: AuthServiceProtocol, profileRepository: ProfileRepositoryProtocol) {
        self.authService = authService
        self.profileRepository = profileRepository
    }
    
    func execute(command: ()) async throws -> Profile {
        do {
            if let myUserId = try await authService.getCurrentUser()?.id {
                return try await profileRepository.getProfileOf(userId: myUserId)
            }
            
            throw DomainError.notFoundError("User not found")
        } catch {
            throw DomainError.dataLayerError(error.localizedDescription)
        }
    }
}
