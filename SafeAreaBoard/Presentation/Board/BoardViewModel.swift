//
//  BoardViewModel.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation
import os.log

final class BoardViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var selectedQuestion: Question?
    @Published var myPost: PostWithOwnership?
    @Published var posts: [PostWithOwnership] = []
    @Published var isError: Bool = false
    
    private let getAllQuestionsUseCase: any GetAllQuestionsUseCaseProtocol
    private let getAllPostsUseCase: any GetAllPostsUseCaseProtocol
    
    private let log = Logger.of("BoardViewModel")
    
    init(
        getAllQuestionsUseCase: any GetAllQuestionsUseCaseProtocol,
        getAllPostsUseCase: any GetAllPostsUseCaseProtocol
    ) {
        self.getAllQuestionsUseCase = getAllQuestionsUseCase
        self.getAllPostsUseCase = getAllPostsUseCase
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
                self.selectedQuestion = questions.first
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
}
