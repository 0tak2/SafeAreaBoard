//
//  WriteViewModel.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/13/25.
//

import Foundation
import os.log

final class WriteViewModel: ObservableObject {
    @Published var selectedQuestion: Question?
    @Published var editingContent: String = ""
    @Published var previousCreatedAt: Date?
    @Published var isError: Bool = false
    @Published var showingAlert: Bool = false
    @Published var isEditMode: Bool = false
    var navigationRouter: BoardNavigationRouter?
    
    private let addPostUseCase: any AddPostUseCaseProtocol
    private let updatePostUseCase: any UpdatePostUseCaseProtocol
    
    private let log = Logger.of("WriteViewModel")
    
    init(
        addPostUseCase: any AddPostUseCaseProtocol,
        updatePostUseCase: any UpdatePostUseCaseProtocol,
        navigationRouter: BoardNavigationRouter? = nil
    ) {
        self.addPostUseCase = addPostUseCase
        self.updatePostUseCase = updatePostUseCase
        self.navigationRouter = navigationRouter
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
                isEditMode = false
                selectedQuestion = nil
                editingContent = ""
                previousCreatedAt = nil
                navigationRouter?.paths.removeLast()
            }
        } catch {
            log.error("save post failed. \(error)")
            
            await MainActor.run {
                isError = true
            }
        }
    }
    
    func configure(isEditMode: Bool, question: Question, post: Post?) {
        if isEditMode && post == nil {
            log.warning("isEditMode is true, but post is nil")
            return
        }
        
        self.isEditMode = isEditMode
        
        if isEditMode {
            selectedQuestion = question
            editingContent = post?.content ?? ""
            previousCreatedAt = post?.createdAt
        } else {
            selectedQuestion = question
            editingContent = ""
            previousCreatedAt = nil
        }
    }
}
