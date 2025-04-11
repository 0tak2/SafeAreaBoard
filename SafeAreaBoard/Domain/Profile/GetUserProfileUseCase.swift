//
//  GetCurrentUserProfileUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/11/25.
//

import Foundation
import os.log

protocol GetProfileUseCaseProtocol: UseCase where Command == UUID, Result == Profile {
}

struct GetProfileUseCase: GetProfileUseCaseProtocol {
    private let authService: AuthServiceProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private let log = Logger.of("GetUserProfileUseCase")
    
    init(authService: AuthServiceProtocol, profileRepository: ProfileRepositoryProtocol) {
        self.authService = authService
        self.profileRepository = profileRepository
    }
    
    func execute(command: UUID) async throws -> Profile {
        do {
            return try await profileRepository.getProfileOf(userId: command)
        } catch {
            throw DomainError.dataLayerError(error.localizedDescription)
        }
    }
}
