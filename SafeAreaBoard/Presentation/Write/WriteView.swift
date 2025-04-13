//
//  WriteView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import SwiftUI

struct WriteView: View {
    @ObservedObject private var viewModel: WriteViewModel
    
    init(viewModel: WriteViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            headerView
            
            TextEditor(text: $viewModel.editingContent)
                .overlay(alignment: .topLeading, content: {
                    if viewModel.editingContent.isEmpty {
                        Text("여기에 경험을 공유해주세요.")
                            .font(.body)
                            .padding(6)
                    }
                })
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle(viewModel.isEditMode ? "수정하기" : "새로운 경험")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                viewModel.saveButtonTapped()
            } label: {
                Text("저장")
            }
            .foregroundStyle(CustomColors.primaryDarker2)
        }
        .animation(.spring, value: viewModel.showingQuestionList)
        .task {
            await viewModel.taskDidStart()
        }
        .alert("내용을 입력해주세요.", isPresented: $viewModel.showingAlert) { }
    }
    
    var headerView: some View {
        VStack {
            HStack {
                HStack {
                    Text(viewModel.selectedQuestion?.content ?? "")
                        .font(.system(size: 22, weight: .bold))
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                Spacer()
                
                Button {
                     viewModel.questionListButtonTapped()
                } label: {
                    Image(systemName: "chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28)
                }
                .foregroundStyle(CustomColors.primary)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(CustomColors.warmGray)
            
            if viewModel.showingQuestionList {
                ScrollView {
                    QuestionListView(questionList: $viewModel.questions) { question in
                        viewModel.questionTapped(question)
                    }
                }
                .frame(maxHeight: 200)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .background(viewModel.showingQuestionList ? CustomColors.primaryLighter : Color.clear)
    }
}

#Preview {
    let supabseClient = SupabaseProvider.shared.supabase
    let postRepository = PostRepository(supabaseClient: supabseClient)
    let authService = AuthService(supabaseClient: supabseClient)
    
    WriteView(
        viewModel: WriteViewModel(
            getAllQuestionsUseCase: GetAllQuestionsUseCase(
                questionRepository: QuestionRepository(supabaseClient: supabseClient),
                postRespository: postRepository,
                authService: authService
            ),
            addPostUseCase: AddPostUseCase(
                postRepository: postRepository,
                authService: authService
            ),
            getMyQuestionUseCase: GetMyQuestionUseCase(
                postRespository: postRepository,
                authService: authService
            )
        )
    )
}
