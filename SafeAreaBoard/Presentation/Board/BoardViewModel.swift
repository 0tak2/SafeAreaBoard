//
//  BoardViewModel.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation
import os.log

final class BoardViewModel: ObservableObject {
    @Published var questions: [QuestionWithAnswerStatus] = []
    @Published var selectedQuestion: QuestionWithAnswerStatus?
    @Published var selectedPost: PostWithOwnership?
    @Published var myPost: PostWithOwnership?
    @Published var posts: [PostWithOwnership] = []
    @Published var isError: Bool = false
    @Published var showingEditSheet: Bool = false
    @Published var showingDetailsSheet: Bool = false
    @Published var showingQuestionList: Bool = false
    @Published var showingDeleteConfirmAlert: Bool = false
    @Published var navigationRouter: BoardNavigationRouter
    
    private let getAllQuestionsUseCase: any GetAllQuestionsUseCaseProtocol
    private let getAllPostsUseCase: any GetAllPostsUseCaseProtocol
    private let addReactionUseCase: any AddReactionUseCaseProtocol
    private let removeReactionUseCase: any RemoveReactionUseCaseProtocol
    private let removePostUseCase: any RemovePostUseCaseProtocol
    
    private let log = Logger.of("BoardViewModel")
    
    init(
        getAllQuestionsUseCase: any GetAllQuestionsUseCaseProtocol,
        getAllPostsUseCase: any GetAllPostsUseCaseProtocol,
        addReactionUseCase: any AddReactionUseCaseProtocol,
        removeReactionUseCase: any RemoveReactionUseCaseProtocol,
        removePostUseCase: any RemovePostUseCaseProtocol,
        navigationRouter: BoardNavigationRouter = BoardNavigationRouter()
    ) {
        self.getAllQuestionsUseCase = getAllQuestionsUseCase
        self.getAllPostsUseCase = getAllPostsUseCase
        self.addReactionUseCase = addReactionUseCase
        self.removeReactionUseCase = removeReactionUseCase
        self.removePostUseCase = removePostUseCase
        self.navigationRouter = navigationRouter
    }
    
    func taskDidStart() async {
        await fetchQuestions()
        if let questionId = selectedQuestion?.questionId {
            await fetchPosts(questionId: questionId)
        }
    }
    
    func fetchQuestions() async {
        do {
            let questions = try await getAllQuestionsUseCase.execute(command: ())
            log.info("fetch questions completed. \(questions)")
            
            await MainActor.run {
                self.questions = questions
                if selectedQuestion == nil {
                    self.selectedQuestion = questions.first
                }
            }
        } catch {
            await MainActor.run {
                isError = true
            }
        }
    }
    
    func fetchPosts(questionId: Int) async {
        do {
            let posts = try await getAllPostsUseCase.execute(command: questionId)
            log.info("fetch posts completed. \(posts)")
            
            await MainActor.run {
                self.posts = posts.filter { post in
                    return !post.isMine
                }
                self.myPost = posts.first { post in
                    return post.isMine
                }
            }
        } catch {
            await MainActor.run {
                isError = true
            }
        }
    }
    
    func menuButtonTapped() {
        showingEditSheet = true
    }
    
    func heartButtonTapped(postId: Int, isLiked: Bool) {
        if isLiked {
            addReaction(postId: postId)
        } else {
            removeReaction(postId: postId)
        }
    }
    
    private func addReaction(postId: Int) {
        Task {
            do {
                try await addReactionUseCase.execute(command: postId)
                log.debug("added reaction to post \(postId)")
            } catch {
                log.error("addReactionUseCase error: \(error)")
                
                await MainActor.run {
                    isError = true
                }
            }
        }
    }
    
    private func removeReaction(postId: Int) {
        Task {
            do {
                try await removeReactionUseCase.execute(command: postId)
                log.debug("revoked reaction from post \(postId)")
            } catch {
                log.error("removeReactionUseCase error: \(error)")
                
                await MainActor.run {
                    isError = true
                }
            }
        }
    }
    
    func deleteButtonTapped() {
        showingDeleteConfirmAlert = true
    }
    
    func deletePostConfirmed() {
        guard let myPost = myPost,
        let id = myPost.id else { return }
        
        removePost(postId: id)
    }
    
    private func removePost(postId: Int) {
        Task {
            do {
                try await removePostUseCase.execute(command: postId)
                log.debug("deleted post \(postId)")
                
                if let questionId = selectedQuestion?.questionId {
                    await fetchQuestions()
                    await fetchPosts(questionId: questionId)
                }
            } catch {
                log.error("removePostUseCase error: \(error)")
                
                await MainActor.run {
                    isError = true
                }
            }
        }
    }
    
    func editButtonTapped() {
        guard let question = selectedQuestion,
              let post = myPost else { return }
        
        navigationRouter.paths.append(.edit(
            Question(
                questionId: question.questionId,
                content: question.content,
                createdAt: question.createdAt,
                updatedAt: question.updatedAt,
                isDeleted: question.isDeleted,
                isHidden: question.isHidden,
                posts: question.posts
            ),
            Post(
                id: post.id,
                content: post.content,
                createdAt: post.createdAt,
                updatedAt: post.updatedAt,
                isDeleted: post.isDeleted,
                isHidden: post.isHidden,
                profileId: post.profileId,
                questionId: post.questionId,
                profile: post.profile,
                reactions: post.reactions
            )
        ))
    }
    
    func writeButtonTapped() {
        guard let question = selectedQuestion else { return }
        
        navigationRouter.paths.append(.edit(
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
    }
    
    func cardViewTapped(post: PostWithOwnership) {
        selectedPost = post
        showingDetailsSheet = true
    }
    
    func questionListButtonTapped() {
        showingQuestionList.toggle()
    }
    
    func questionTapped(_ question: QuestionWithAnswerStatus) {
        selectedQuestion = question
        Task {
            await questionChanged()
        }
    }
    
    func questionChanged() async {
        if let questionId = selectedQuestion?.questionId {
            await fetchPosts(questionId: questionId)
        }
    }
}
