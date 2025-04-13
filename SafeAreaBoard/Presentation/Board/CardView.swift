//
//  CardView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import SwiftUI

struct CardView: View {
    private var post: PostWithOwnership
    
    init(post: PostWithOwnership) {
        self.post = post
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: .init(width: 8, height: 8), style: .continuous)
                .foregroundStyle(CustomColors.warmGrayLigher1)
            
            VStack(spacing: 16) {
                HStack { // MARK: Header
                    Text(post.profile?.nickname ?? "")
                        .foregroundStyle(.black)
                        .font(.headline)
                    
                    if post.isMine {
                        Text("나")
                            .foregroundStyle(.black)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    if post.isMine {
                        Button {
                            //
                        } label: {
                            Image(systemName: "ellipsis")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                        }
                        .foregroundStyle(CustomColors.warmGrayDarker1)
                    }
                }
                
                VStack(alignment: .leading) { // MARK: Content
                    Text(post.content ?? "")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .frame(height: 110)
                
                HStack { // MARK: Footer
                    Button {
                        //
                    } label: {
                        Image(systemName: "heart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                    }
                    .foregroundStyle(CustomColors.warmGrayDarker1)
                    
                    Text(String(post.reactions?.count ?? 0))
                        .font(.callout)
                    
                    Spacer()
                    
                    Text(post.createdAt?.relativeLocalizedDescription ?? "")
                        .font(.callout)
                }
            }
            .padding(16)
        }
    }
}

#Preview {
    CardView(
        post: .init(
            id: nil,
            content: "테스트",
            createdAt: Date(),
            updatedAt: Date(),
            isDeleted: false,
            isHidden: false,
            profileId: UUID(),
            isMine: true,
            questionId: nil,
            profile: Profile(userId: nil, nickname: "Bob"),
            reactions: []))
}
