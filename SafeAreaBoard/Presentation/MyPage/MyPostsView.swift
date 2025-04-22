//
//  MyPostsView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/18/25.
//

import SwiftUI

struct MyPostsView: View {
    @State private var isError: Bool = false
    @StateObject private var viewModel: MyPostsViewModel
    @ObservedObject private var navigationRouter: NavigationRouter
    @State private var isLoading: Bool = false
    
    init(viewModel: MyPostsViewModel, navigationRouter: NavigationRouter) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._navigationRouter = ObservedObject(wrappedValue: navigationRouter)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.myPosts, id: \.id) { post in
                    makeQuestionAndPostView(post: post)
                        .id(post.id)
                }
            }
        }
        .confirmationDialog("편집 메뉴", isPresented: $viewModel.showingEditSheet) {
            Button("수정", role: .none) {
                guard let question = viewModel.selectedPost?.question,
                      let postWithQuestion = viewModel.selectedPost else {
                    return
                }
                
                let post = Post(
                    id: postWithQuestion.id,
                    content: postWithQuestion.content,
                    createdAt: postWithQuestion.createdAt,
                    updatedAt: postWithQuestion.updatedAt,
                    isDeleted: false,
                    isHidden: false,
                    profileId: postWithQuestion.profileId,
                    questionId: postWithQuestion.questionId,
                    question: postWithQuestion.question,
                    profile: postWithQuestion.profile,
                    reactions: postWithQuestion.reactions
                )
                
                navigationRouter.goForward(to: .edit(question, post))
            }
            Button("삭제", role: .destructive) {
                viewModel.deleteButtonTapped()
            }
            Button("취소", role: .cancel) {}
        }
        .alert("정말 삭제하시겠습니까?", isPresented: $viewModel.showingDeleteConfirmAlert, actions: {
            Button("삭제", role: .destructive) {
                viewModel.deletePostConfirmed()
            }
            Button("취소", role: .cancel) {
            }
        })
        .sheet(isPresented: $viewModel.showingDetailsSheet) {
            DetailView(post: $viewModel.selectedPost)
                .presentationDetents([.fraction(0.7)])
                .presentationDragIndicator(.visible)
        }
        .navigationTitle("내가 공유한 경험")
        .task(isLoading: $isLoading) {
            await viewModel.loadPosts()
        }
        .loading(isLoading: isLoading)
    }
    
    func makeQuestionAndPostView(post: PostWithQuestion) -> some View {
        return VStack {
            HStack {
                Text(post.question?.content ?? "")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(CustomColors.warmGrayDarker2)
                
                Spacer()
            }
            
            CardView(
                post: post,
                editButtonTapped: viewModel.menuButtonTapped,
                heartButtonTapped: viewModel.heartButtonTapped(postId:isLiked:)
            )
            .onTapGesture {
                viewModel.cardViewTapped(post: post)
            }
        }
        .padding(16)
    }
}

#Preview {
    let postRepository = PostRepository(supabaseClient: SupabaseProvider.shared.supabase)
    let authService = AuthService(supabaseClient: SupabaseProvider.shared.supabase)
    let reactionRepository = ReactionRepository(supabaseClient: SupabaseProvider.shared.supabase)
    
    MyPostsView(
        viewModel: MyPostsViewModel(
            getAllMyPostsUseCase: GetAllMyPostsUseCase(
                postRespository: PostRepository(supabaseClient: SupabaseProvider.shared.supabase),
                authService: AuthService(supabaseClient: SupabaseProvider.shared.supabase)
            ),
            removePostUseCase: RemovePostUseCase(
                postRepository: postRepository,
                authService: authService
            ),
            addReactionUseCase: AddReactionUseCase(
                reactionRepository: reactionRepository,
                authService: authService
            ),
            removeReactionUseCase: RemoveReactionUseCase(
                reactionRepository: reactionRepository,
                authService: authService
            )
        ),
        navigationRouter: NavigationRouter()
    )
}
