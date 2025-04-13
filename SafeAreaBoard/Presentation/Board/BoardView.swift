//
//  BoardView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import SwiftUI

struct BoardView: View {
    @StateObject private var viewModel: BoardViewModel
    
    init(viewModel: BoardViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            Spacer()
                .frame(height: 32)
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 24) {
                    if let myPost = viewModel.myPost {
                        CardView(post: myPost)
                    }
                    
                    ForEach(viewModel.posts, id: \.id) { post in
                        CardView(post: post)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .task {
            await viewModel.taskDidStart()
        }
    }
    
    var headerView: some View {
        VStack {
            HStack {
                HStack {
                    Text(viewModel.selectedQuestion?.content ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                .frame(width: 264)
                
                Spacer()
                
                Button {
                    //
                } label: {
                    Image(systemName: "chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36)
                }
                .foregroundStyle(CustomColors.primary)

            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    BoardView(viewModel: BoardViewModel(getAllQuestionsUseCase: GetAllQuestionsUseCase(questionRepository: QuestionRepository(supabaseClient: SupabaseProvider.shared.supabase)), getAllPostsUseCase: GetAllPostsUseCase(postRepository: PostRepository(supabaseClient: SupabaseProvider.shared.supabase), authService: AuthService(supabaseClient: SupabaseProvider.shared.supabase))))
}
