//
//  DetailView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/13/25.
//

import SwiftUI

struct DetailView: View {
    @Binding var post: PostWithOwnership?
    
    var shouldShowUpdatedDate: Bool {
        guard let post = post,
              let createdAt = post.createdAt,
              let updatedAt = post.updatedAt else {
            return false
        }
        
        return createdAt != updatedAt
    }
    
    var reactorNicknames: String {
        guard let post = post,
              let reactions = post.reactions else { return "" }
        
        return reactions.compactMap { reaction in
            guard let nickname = reaction.profile?.nickname else {
                return nil
            }
            
            return nickname
        }
        .joined(separator: ", ")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Text("\(post?.profile?.nickname ?? "")의 경험")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                Text("\(post?.content ?? "")")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                VStack {
                    Text("\(post?.createdAt?.localizedDescription ?? "")")
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    if shouldShowUpdatedDate {
                        Text("\(post?.updatedAt?.localizedDescription ?? "") 수정")
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                }
                .font(.footnote)
                
                if let post = post,
                   let reactions = post.reactions,
                   !reactions.isEmpty {
                    VStack {
                        Text("\(post.profile?.nickname ?? "")에게 공감한 러너")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        Text(reactorNicknames)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .font(.footnote)
                }
            }
        }
        .padding(32)
    }
}

#Preview {
    DetailView(
        post: .constant(
            PostWithOwnership(
                id: nil,
                content: "비가 오던 어느 날 오후, 밖에 나가지 못해 속상해하던 저를 위해 엄마가 따뜻한 담요를 덮어주고 창가에 함께 앉아 동화책을 읽어주셨어요. 빗소리와 엄마의 차분한 목소리가 어우러져서 마음이 참 편안했던 기억이에요. 책을 다 읽고 나서 엄마가 조용히 등을 토닥여주셨던 그 감촉이 아직도 생생하게 남아 있어요.",
                createdAt: Date(),
                updatedAt: Date.distantFuture,
                isDeleted: false,
                isHidden: false,
                profileId: UUID(),
                isMine: false,
                questionId: nil,
                profile: .init(userId: nil, nickname: "Bob"),
                reactions: [
                    .init(id: nil, type: "heart", createdAt: Date(), profileId: nil, profile: .init(userId: nil, nickname: "Bob"), postId: nil),
                    .init(id: nil, type: "heart", createdAt: Date(), profileId: nil, profile: .init(userId: nil, nickname: "ChalBob"), postId: nil),
                    .init(id: nil, type: "heart", createdAt: Date(), profileId: nil, profile: .init(userId: nil, nickname: "BoriBob"), postId: nil),
                ],
                isReactedByMyself: true
            )
        )
    )
}
