//
//  WriteViewModel.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/13/25.
//

import Foundation
import os.log

final class WriteViewModel: ObservableObject {
    @Published var questions: [QuestionWithAnswerStatus] = []
    @Published var selectedQuestion: QuestionWithAnswerStatus?
    @Published var editingContent: String = ""
    @Published var isError: Bool = false
    @Published var showingQuestionList: Bool = false
    @Published var showingAlert: Bool = false
    
    private let getAllQuestionsUseCase: any GetAllQuestionsUseCaseProtocol
    private let addPostUseCase: any AddPostUseCaseProtocol
    var tabRouter: TabRouter?
    
    private let log = Logger.of("WriteViewModel")
    
    init(
        getAllQuestionsUseCase: any GetAllQuestionsUseCaseProtocol,
        addPostUseCase: any AddPostUseCaseProtocol
    ) {
        self.getAllQuestionsUseCase = getAllQuestionsUseCase
        self.addPostUseCase = addPostUseCase
    }
    
    func taskDidStart() async {
        await fetchQuestions()
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
    
    func saveButtonTapped() {
        guard !editingContent.isEmpty else {
            showingAlert = true
            return
        }
        
        Task {
            await savePost()
        }
    }
    
    private func savePost() async {
        do {
            let _ = try await addPostUseCase.execute(command: UpdatePostParams(
                content: editingContent,
                createdAt: Date(),
                updatedAt: Date(),
                profileId: nil,
                questionId: selectedQuestion?.questionId,
                isDeleted: false,
                isHidden: false
            ))
            
            await MainActor.run {
                editingContent = ""
                
                tabRouter?.currentTab = .board
            }
        } catch {
            log.error("save post failed. \(error)")
            isError = true
        }
    }
    
    func questionListButtonTapped() {
        showingQuestionList.toggle()
    }
    
    func questionTapped(_ question: QuestionWithAnswerStatus) {
        selectedQuestion = question
    }
}
