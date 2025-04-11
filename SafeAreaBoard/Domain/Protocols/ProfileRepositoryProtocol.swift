//
//  ProfileRepositoryProtocol.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/11/25.
//

import Foundation

protocol ProfileRepositoryProtocol {
    func getProfileOf(userId: UUID) async throws -> Profile
    func updateProfile(of userId: UUID, to updateDTO: UpdateProfileParams) async throws -> Profile
}
