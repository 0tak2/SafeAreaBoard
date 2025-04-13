//
//  BoardView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import SwiftUI

struct BoardView: View {
    @StateObject private var viewModel: BoardViewModel
    
    init(viewModel: BoardViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            Spacer()
                .frame(height: 32)
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 24) {
                    if let myPost = viewModel.myPost {
                        CardView(post: myPost) {
                            viewModel.menuButtonTapped()
                        } heartButtonTapped: { postId, isLiked in
                            viewModel.heartButtonTapped(postId: postId, isLiked: isLiked)
                        }
                        .onTapGesture {
                            viewModel.cardViewTapped(post: myPost)
                        }
                    }
                    
                    ForEach(viewModel.posts, id: \.id) { post in
                        CardView(post: post, editButtonTapped: nil) { postId, isLiked in
                            viewModel.heartButtonTapped(postId: postId, isLiked: isLiked)
                        }
                        .onTapGesture {
                            viewModel.cardViewTapped(post: post)
                        }
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .task {
            await viewModel.taskDidStart()
        }
        .confirmationDialog("편집 메뉴", isPresented: $viewModel.showingEditSheet) {
            Button("수정", role: .none) {}
            Button("삭제", role: .destructive) {}
            Button("취소", role: .cancel) {}
        }
        .sheet(isPresented: $viewModel.showingDetailsSheet) {
            DetailView(post: $viewModel.selectedPost)
                .presentationDetents([.fraction(0.7)])
                .presentationDragIndicator(.visible)
        }
    }
    
    var headerView: some View {
        VStack {
            HStack {
                HStack {
                    Text(viewModel.selectedQuestion?.content ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                .frame(width: 264)
                
                Spacer()
                
                Button {
                    //
                } label: {
                    Image(systemName: "chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36)
                }
                .foregroundStyle(CustomColors.primary)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let authService = AuthService(supabaseClient: SupabaseProvider.shared.supabase)
    let reactionRepoitory = ReactionRepository(supabaseClient: SupabaseProvider.shared.supabase)
    
    BoardView(viewModel: BoardViewModel(getAllQuestionsUseCase: GetAllQuestionsUseCase(questionRepository: QuestionRepository(supabaseClient: SupabaseProvider.shared.supabase)), getAllPostsUseCase: GetAllPostsUseCase(postRepository: PostRepository(supabaseClient: SupabaseProvider.shared.supabase), authService: authService), addReactionUseCase: AddReactionUseCase(reactionRepository: reactionRepoitory, authService: authService), removeReactionUseCase: RemoveReactionUseCase(reactionRepository: reactionRepoitory, authService: authService)))
}
