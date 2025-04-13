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
    
    private let getAllQuestionsUseCase: any GetAllQuestionsUseCaseProtocol
    private let getAllPostsUseCase: any GetAllPostsUseCaseProtocol
    private let addReactionUseCase: any AddReactionUseCaseProtocol
    private let removeReactionUseCase: any RemoveReactionUseCaseProtocol
    private let updateLastQuestionIdUseCaseProtocol: any UpdateLastQuestionIdUseCaseProtocol
    var tabRouter: TabRouter?
    
    private let log = Logger.of("BoardViewModel")
    
    init(
        getAllQuestionsUseCase: any GetAllQuestionsUseCaseProtocol,
        getAllPostsUseCase: any GetAllPostsUseCaseProtocol,
        addReactionUseCase: any AddReactionUseCaseProtocol,
        removeReactionUseCase: any RemoveReactionUseCaseProtocol,
        updateLastQuestionIdUseCase: any UpdateLastQuestionIdUseCaseProtocol
    ) {
        self.getAllQuestionsUseCase = getAllQuestionsUseCase
        self.getAllPostsUseCase = getAllPostsUseCase
        self.addReactionUseCase = addReactionUseCase
        self.removeReactionUseCase = removeReactionUseCase
        self.updateLastQuestionIdUseCaseProtocol = updateLastQuestionIdUseCase
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
                    
                    if let questionId = selectedQuestion?.questionId {
                        updateLastQuestionId(questionId)
                    }
                }
            }
        } catch {
            await MainActor.run {
                isError = true
            }
        }
    }
    
    private func updateLastQuestionId(_ questionId: Int) {
        do {
            try updateLastQuestionIdUseCaseProtocol.execute(command: questionId)
        } catch {
            log.error("UserDefaults update error: \(error)")
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
        // TODO: Delete post
        print("deleteButtonTapped")
    }
    
    func editButtonTapped() {
        tabRouter?.currentTab = .edit
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
            updateLastQuestionId(questionId)
        }
    }
    
    enum Path: Hashable {
        case edit
    }
}
