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
    @Published var previousCreatedAt: Date?
    @Published var isError: Bool = false
    @Published var showingAlert: Bool = false
    @Published var isEditMode: Bool = false
    
    private let getAllQuestionsUseCase: any GetAllQuestionsUseCaseProtocol
    private let addPostUseCase: any AddPostUseCaseProtocol
    private let getMyQuestionUseCase: any GetMyQuestionUseCaseProtocol
    private let updatePostUseCase: any UpdatePostUseCaseProtocol
    
    private let log = Logger.of("WriteViewModel")
    
    init(
        getAllQuestionsUseCase: any GetAllQuestionsUseCaseProtocol,
        addPostUseCase: any AddPostUseCaseProtocol,
        getMyQuestionUseCase: any GetMyQuestionUseCaseProtocol,
        updatePostUseCase: any UpdatePostUseCaseProtocol
    ) {
        self.getAllQuestionsUseCase = getAllQuestionsUseCase
        self.addPostUseCase = addPostUseCase
        self.getMyQuestionUseCase = getMyQuestionUseCase
        self.updatePostUseCase = updatePostUseCase
    }
    
    func taskDidStart() async {
        await fetchQuestions()
    }
    
    func fetchQuestions() async {
        do {
            let questions = try await getAllQuestionsUseCase.execute(command: ())
            log.info("fetch questions completed. \(questions)")
            
            // can two tasks below be integrated?
            await MainActor.run {
                self.questions = questions
                
                if selectedQuestion == nil {
                    selectedQuestion = questions.first
                }
            }
            
            if let didAnswer = selectedQuestion?.didAnswer,
               didAnswer,
               let questionId = selectedQuestion?.questionId {
                let post = try await getMyQuestionUseCase.execute(command: questionId)
                await MainActor.run {
                    isEditMode = didAnswer
                    editingContent = post?.content ?? ""
                    previousCreatedAt = post?.createdAt
                }
            } else {
                await MainActor.run {
                    isEditMode = false
                    editingContent = ""
                    previousCreatedAt = nil
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
            if isEditMode {
                let _ = try await updatePostUseCase.execute(command: UpdatePostParams(
                    content: editingContent,
                    createdAt: previousCreatedAt ?? Date(),
                    updatedAt: Date(),
                    profileId: nil,
                    questionId: selectedQuestion?.questionId,
                    isDeleted: false,
                    isHidden: false
                ))
            } else {
                let _ = try await addPostUseCase.execute(command: UpdatePostParams(
                    content: editingContent,
                    createdAt: Date(),
                    updatedAt: Date(),
                    profileId: nil,
                    questionId: selectedQuestion?.questionId,
                    isDeleted: false,
                    isHidden: false
                ))
            }
            
            await MainActor.run {
                editingContent = ""
            }
        } catch {
            log.error("save post failed. \(error)")
            isError = true
        }
    }
    
    func questionTapped(_ question: QuestionWithAnswerStatus) {
        selectedQuestion = question
        Task {
            await fetchQuestions()
        }
    }
}
