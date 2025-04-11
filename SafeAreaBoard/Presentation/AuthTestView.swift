//
//  AuthTestView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/11/25.
//

import SwiftUI

struct AuthTestView: View {
    @State private var profile: Profile?
    @State private var isError: Bool = false
    @EnvironmentObject private var container: DIContainerEnvironment
    
    var body: some View {
        VStack {
            if let profile = profile {
                Text("user id: \(String(describing: profile.userId))")
                Text("user nickname: \(String(describing: profile.nickname))")
            } else {
                Text("N/A")
            }
            
            if isError {
                Text("에러")
            }
            
            Button("로그아웃") {
                Task {
                    print("start signOut")
                    let usecase =  container.resolve((any LogoutUseCaseProtocol).self)!
                    do {
                        try await usecase.execute(command: ())
                    } catch {
                        print("error occured \(error)")
                        isError = true
                    }
                }
            }
        }
        .task {
            Task {
                let getCurrentUserUseCase =  container.resolve((any GetCurrentUserUseCaseProtocol).self)!
                let getProfileUseCase =  container.resolve((any GetProfileUseCaseProtocol).self)!
                do {
                    if let user = try await getCurrentUserUseCase.execute(command: ()) {
                        let profile = try await getProfileUseCase.execute(command: user.id)
                        self.profile = profile
                    }
                } catch {
                    print("error occured \(error)")
                    isError = true
                }
            }
        }
    }
}

#Preview {
    AuthTestView()
}
