//
//  BoardView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import SwiftUI

struct BoardContentView: View {
    @StateObject private var viewModel: BoardViewModel
    @ObservedObject private var navigationRouter: NavigationRouter
    @State private var isLoading: Bool = false
    @State private var showingError: Bool = false
    
    init(viewModel: BoardViewModel, navigationRouter: NavigationRouter) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.navigationRouter = navigationRouter
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView(showsIndicators: false) {
                if viewModel.myPost == nil {
                    HStack {
                        Spacer()
                        
                        Button {
                            guard let question = viewModel.selectedQuestion else { return }
                            
                            navigationRouter.goForward(to: .edit(
                                Question(
                                    questionId: question.questionId,
                                    content: question.content,
                                    createdAt: question.createdAt,
                                    updatedAt: question.updatedAt,
                                    isDeleted: question.isDeleted,
                                    isHidden: question.isHidden,
                                    posts: question.posts
                                ),
                                nil
                            ))
                        } label: {
                            Text("작성")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(.black)
                                .padding(.init(top: 8, leading: 24, bottom: 8, trailing: 24))
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(CustomColors.primary)
                                )
                        }
                    }
                    
                    Spacer()
                        .frame(height: 16)
                }
                
                if viewModel.myPost == nil,
                   viewModel.posts.isEmpty {
                    Text("아직 등록된 경험이 없습니다.\n작성 버튼을 눌러 경험을 공유해보세요.")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                LazyVStack(spacing: 24) {
                    if let myPost = viewModel.myPost {
                        CardView(post: myPost, editButtonTapped: { _ in
                            viewModel.menuButtonTapped()
                        }, heartButtonTapped: { postId, isLiked in
                            viewModel.heartButtonTapped(postId: postId, isLiked: isLiked)
                        })
                        .id(myPost.id)
                        .onTapGesture {
                            viewModel.cardViewTapped(post: myPost)
                        }
                    }
                    
                    ForEach(viewModel.posts, id: \.id) { post in
                        CardView(post: post, editButtonTapped: nil) { postId, isLiked in
                            viewModel.heartButtonTapped(postId: postId, isLiked: isLiked)
                        }
                        .id(post.id)
                        .onTapGesture {
                            viewModel.cardViewTapped(post: post)
                        }
                    }
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .task(isLoading: $isLoading) {
            await viewModel.taskDidStart()
        }
        .loading(isLoading: isLoading)
        .confirmationDialog("편집 메뉴", isPresented: $viewModel.showingEditSheet) {
            Button("수정", role: .none) {
                guard let selectedQuestion = viewModel.selectedQuestion,
                      let myPost = viewModel.myPost else {
                    return
                }
                
                navigationRouter.goForward(to: .edit(
                    Question(
                        questionId: selectedQuestion.questionId,
                        content: selectedQuestion.content,
                        createdAt: selectedQuestion.createdAt,
                        updatedAt: selectedQuestion.updatedAt,
                        isDeleted: selectedQuestion.isDeleted,
                        isHidden: selectedQuestion.isHidden,
                        posts: selectedQuestion.posts
                    ),
                    Post(
                        id: myPost.id,
                        content: myPost.content,
                        createdAt: myPost.createdAt,
                        updatedAt: myPost.updatedAt,
                        isDeleted: myPost.isDeleted,
                        isHidden: myPost.isHidden,
                        profileId: myPost.profileId,
                        questionId: myPost.questionId,
                        question: nil,
                        profile: myPost.profile,
                        reactions: myPost.reactions
                    )
                ))
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
        .animation(.spring, value: viewModel.showingQuestionList)
        .onChange(of: viewModel.errorMessage) { _, newValue in
            if newValue != nil {
                showingError = true
            } else {
                showingError = false
            }
        }
        .error(message: viewModel.errorMessage, isShowing: showingError)
    }
    
    var headerView: some View {
        VStack {
            HStack {
                Text(viewModel.selectedQuestion?.content ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(minWidth: 264, maxWidth: 300, alignment: .leading)
                
                Spacer()
                
                Button {
                    viewModel.questionListButtonTapped()
                } label: {
                    Image(systemName: viewModel.showingQuestionList ? "chevron.up" : "chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36)
                }
                .foregroundStyle(CustomColors.primary)
                .padding(.horizontal, 4)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if viewModel.showingQuestionList {
                ScrollView {
                    QuestionListView(questionList: viewModel.questions) { question in
                        viewModel.questionTapped(question)
                    }
                }
                .frame(maxHeight: 200)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .background(viewModel.showingQuestionList ? CustomColors.primaryLighter : Color.clear)
    }
}

#Preview {
    let authService = AuthService(supabaseClient: SupabaseProvider.shared.supabase)
    let postRepository = PostRepository(supabaseClient: SupabaseProvider.shared.supabase)
    let reactionRepoitory = ReactionRepository(supabaseClient: SupabaseProvider.shared.supabase)
    
    BoardContainerView(viewModel: BoardViewModel(
        getAllQuestionsUseCase: GetAllQuestionsUseCase(
            questionRepository: QuestionRepository(supabaseClient: SupabaseProvider.shared.supabase),
            postRespository: PostRepository(supabaseClient: SupabaseProvider.shared.supabase),
            authService: authService
        ),
        getAllPostsUseCase: GetAllPostsUseCase(
            postRepository: postRepository,
            authService: authService
        ),
        addReactionUseCase: AddReactionUseCase(
            reactionRepository: reactionRepoitory,
            authService: authService
        ),
        removeReactionUseCase: RemoveReactionUseCase(
            reactionRepository: reactionRepoitory,
            authService: authService
        ),
        removePostUseCase: RemovePostUseCase(
            postRepository: postRepository,
            authService: authService
        )
    ), navigationRouter: NavigationRouter())
}
