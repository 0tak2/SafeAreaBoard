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
    @Published var showingQuestionList: Bool = false
    @Published var showingAlert: Bool = false
    @Published var isEditMode: Bool = false
    
    private let getAllQuestionsUseCase: any GetAllQuestionsUseCaseProtocol
    private let addPostUseCase: any AddPostUseCaseProtocol
    private let getMyQuestionUseCase: any GetMyQuestionUseCaseProtocol
    private let getLastQuestionIdUseCase: any GetLastQuestionIdUseCaseProtocol
    var tabRouter: TabRouter?
    
    private let log = Logger.of("WriteViewModel")
    
    init(
        getAllQuestionsUseCase: any GetAllQuestionsUseCaseProtocol,
        addPostUseCase: any AddPostUseCaseProtocol,
        getMyQuestionUseCase: any GetMyQuestionUseCaseProtocol,
        getLastQuestionIdUseCase: any GetLastQuestionIdUseCaseProtocol
    ) {
        self.getAllQuestionsUseCase = getAllQuestionsUseCase
        self.addPostUseCase = addPostUseCase
        self.getMyQuestionUseCase = getMyQuestionUseCase
        self.getLastQuestionIdUseCase = getLastQuestionIdUseCase
    }
    
    func taskDidStart() async {
        await fetchQuestions()
    }
    
    func fetchQuestions(isPreferUserDefaults: Bool = true) async {
        do {
            let lastQuestionIdOrNil = try getLastQuestionIdUseCase.execute(command: ())
            
            let questions = try await getAllQuestionsUseCase.execute(command: ())
            log.info("fetch questions completed. \(questions)")
            
            // can two tasks below be integrated?
            await MainActor.run {
                self.questions = questions
                
                if isPreferUserDefaults, // userDefaults에 저장된 최근 질문이 우선한다
                   let lastQuestionId = lastQuestionIdOrNil {
                    selectedQuestion = questions.first(where: { $0.questionId == lastQuestionId })
                }
                
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
            let _ = try await addPostUseCase.execute(command: UpdatePostParams(
                content: editingContent,
                createdAt: previousCreatedAt ?? Date(),
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
        Task {
            await fetchQuestions(isPreferUserDefaults: false)
        }
    }
}
