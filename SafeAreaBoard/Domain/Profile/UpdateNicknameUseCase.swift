//
//  UpdateProfileUseCase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/11/25.
//

import Foundation
import os.log

protocol UpdateNicknameUseCaseProtocol: UseCase where Command == UpdateProfileCommand<UpdateProfileParams>, Result == Profile {
}

struct UpdateNicknameUseCase: UpdateNicknameUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol
    private let log = Logger.of("UpdateNicknameUseCase")
    
    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }
    
    func execute(command: UpdateProfileCommand<UpdateProfileParams>) async throws -> Profile {
        do {
            return try await profileRepository.updateProfile(of: command.userId, to: command.params)
        } catch {
            throw DomainError.dataLayerError(error.localizedDescription)
        }
    }
}
