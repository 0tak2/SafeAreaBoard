//
//  UpdateProfileUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/11/25.
//

import Foundation
import os.log

protocol UpdateFCMTokenUseCaseProtocol: UseCase where Command == String, Result == Void {
}

struct UpdateFCMTokenUseCase: UpdateFCMTokenUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let log = Logger.of("UpdateFCMTokenUseCase")
    
    init(profileRepository: ProfileRepositoryProtocol, authService: AuthServiceProtocol) {
        self.profileRepository = profileRepository
        self.authService = authService
    }
    
    func execute(command: String) async throws {
        do {
            if let myUserId = try await authService.getCurrentUser()?.id {
                try await profileRepository.updateFCMToken(of: myUserId, to: command)
            } else {
                log.error("session expired...")
                throw DomainError.invalidSession("userId를 얻지 못했습니다.")
            }
        } catch {
            throw DomainError.dataLayerError(error.localizedDescription)
        }
    }
}
