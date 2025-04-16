//
//  ProfileRepository.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/11/25.
//

import Foundation
import Supabase

final class ProfileRepository: ProfileRepositoryProtocol {
    private let supabaseClient: SupabaseClient
    private let tableName = "profiles"
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    func getProfileOf(userId: UUID) async throws -> Profile {
        let profile: Profile = try await supabaseClient
            .from(tableName)
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        
        return profile
    }
    
    func updateProfile(of userId: UUID, to updateDTO: UpdateProfileParams) async throws -> Profile {
        try await supabaseClient
            .from(tableName)
            .update(updateDTO)
            .eq("id", value: userId)
            .execute()
        
        return Profile(userId: userId, nickname: updateDTO.nickname)
    }
    
    func updateFCMToken(of userId: UUID, to token: String) async throws {
        try await supabaseClient
            .from(tableName)
            .update(UpdateFCMTokenProfileParams(fcmToken: token))
            .eq("id", value: userId)
            .execute()
    }
}
