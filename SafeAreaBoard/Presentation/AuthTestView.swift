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
                    let usecase: any LogoutUseCaseProtocol = Resolver.resolve()
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
                let getCurrentUserUseCase: any GetCurrentUserUseCaseProtocol =  Resolver.resolve()
                let getProfileUseCase: any GetCurrentUserProfileUseCaseProtocol = Resolver.resolve()
                do {
                    if let user = try await getCurrentUserUseCase.execute(command: ()) {
                        let profile = try await getProfileUseCase.execute(command: ())
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
