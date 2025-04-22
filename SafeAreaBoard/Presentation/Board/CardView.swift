//
//  CardView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import SwiftUI

struct CardView: View {
    private var post: PostRenderable
    private var editButtonTapped: ((_ postId: Int) -> Void)?
    private var heartButtonTapped: ((_ postId: Int, _ isAddingReaction: Bool) -> Void)?
    
    @State private var isLikedByMySelf = false
    @State private var likesCount = 0
    
    init(post: PostRenderable, editButtonTapped: ( (Int) -> Void)? = nil, heartButtonTapped: ( (_: Int, _: Bool) -> Void)? = nil) {
        self.post = post
        self.editButtonTapped = editButtonTapped
        self.heartButtonTapped = heartButtonTapped
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
                            if let postId = post.id {
                                editButtonTapped?(postId)
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                        }
                        .foregroundStyle(CustomColors.warmGrayDarker1)
                        .padding(.leading, 16)
                        .frame(height: 32)
                        .contentShape(Rectangle())
                    }
                }
                
                VStack(alignment: .leading) { // MARK: Content
                    Text(post.content ?? "")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .frame(height: 110)
                
                HStack { // MARK: Footer
                    Button {
                        guard let postId = post.id else { return }
                        
                        isLikedByMySelf.toggle()
                        heartButtonTapped?(postId, isLikedByMySelf)
                        if isLikedByMySelf {
                            likesCount += 1
                        } else {
                            likesCount -= 1
                        }
                    } label: {
                        Image(systemName: isLikedByMySelf ? "heart.fill" : "heart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                    }
                    .foregroundStyle(isLikedByMySelf ? .red : CustomColors.warmGrayDarker1)
                    
                    Text(String(likesCount))
                        .font(.callout)
                    
                    Spacer()
                    
                    Text(post.createdAt?.relativeLocalizedDescription ?? "")
                        .font(.callout)
                }
            }
            .padding(16)
        }
        .sensoryFeedback(.impact(weight: .heavy, intensity: 1), trigger: likesCount)
        .onAppear() {
            isLikedByMySelf = post.isReactedByMyself
            likesCount = post.reactions?.count ?? 0
        }
    }
}

#Preview {
    CardView(
        post: PostWithOwnership(
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
            reactions: [],
            isReactedByMyself: false))
}
