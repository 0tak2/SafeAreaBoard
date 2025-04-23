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
    @Published var errorMessage: String?
    @Published var showingEditSheet: Bool = false
    @Published var showingDetailsSheet: Bool = false
    @Published var showingQuestionList: Bool = false
    @Published var showingDeleteConfirmAlert: Bool = false
    @Published var showingHeartParticle: Bool = false
    
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
        removePostUseCase: any RemovePostUseCaseProtocol
    ) {
        self.getAllQuestionsUseCase = getAllQuestionsUseCase
        self.getAllPostsUseCase = getAllPostsUseCase
        self.addReactionUseCase = addReactionUseCase
        self.removeReactionUseCase = removeReactionUseCase
        self.removePostUseCase = removePostUseCase
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
                errorMessage = "질문을 불러오는 중 오류가 발생했습니다."
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
                errorMessage = "경험을 불러오는 중 오류가 발생했습니다."
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
                
                await  startHeartEffect()
            } catch {
                log.error("addReactionUseCase error: \(error)")
                
                await MainActor.run {
                    errorMessage = "하트를 추가하는 중 오류가 발생했습니다."
                }
            }
        }
    }
    
    private func startHeartEffect() async {
        await MainActor.run {
            showingHeartParticle = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.showingHeartParticle = false
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
                    errorMessage = "하트를 삭제하는 중 오류가 발생했습니다."
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
                    errorMessage = "경험을 삭제하는 중 오류가 발생했습니다."
                }
            }
        }
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
