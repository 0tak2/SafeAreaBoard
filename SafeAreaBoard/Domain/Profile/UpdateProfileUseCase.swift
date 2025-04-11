//
//  UpdateProfileUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/11/25.
//

import Foundation
import os.log

protocol UpdateProfileUseCaseProtocol: UseCase where Command == UpdateProfileCommand, Result == Profile {
}

struct UpdateProfileUseCase: UpdateProfileUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol
    private let log = Logger.of("UpdateProfileUseCase")
    
    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }
    
    func execute(command: UpdateProfileCommand) async throws -> Profile {
        do {
            return try await profileRepository.updateProfile(of: command.userId, to: command.params)
        } catch {
            throw DomainError.dataLayerError(error.localizedDescription)
        }
    }
}
