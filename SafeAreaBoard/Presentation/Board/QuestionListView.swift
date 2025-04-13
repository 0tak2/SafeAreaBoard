//
//  QuestionListView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/13/25.
//

import SwiftUI

struct QuestionListView: View {
    @Binding var questionList: [QuestionWithAnswerStatus]
    var questionSelected: ((QuestionWithAnswerStatus) -> Void)?
    
    init(questionList: Binding<[QuestionWithAnswerStatus]>, questionSelected: ( (QuestionWithAnswerStatus) -> Void)? = nil) {
        self._questionList = questionList
        self.questionSelected = questionSelected
    }
    
    var body: some View {
        VStack {
            ForEach(questionList, id: \.questionId) { question in
                VStack {
                    HStack {
                        if question.didAnswer {
                            Image(systemName: "checkmark.circle")
                        } else {
                            Image(systemName: "circle")
                        }
                        
                        Text(question.content ?? "")
                        
                        Spacer()
                    }
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                }
                .onTapGesture {
                    questionSelected?(question)
                }
                .frame(height: 44)
            }
        }
    }
}

#Preview {
    QuestionListView(questionList: .constant(
        [
            .init(questionId: nil, content: "어린 시절 기억에 남는 순간이 있나요?", createdAt: nil, updatedAt: nil, isDeleted: nil, isHidden: nil, posts: nil, didAnswer: true),
            .init(questionId: nil, content: "어린 시절 기억에 남는 순간이 있나요?", createdAt: nil, updatedAt: nil, isDeleted: nil, isHidden: nil, posts: nil, didAnswer: true),
            .init(questionId: nil, content: "어린 시절 기억에 남는 순간이 있나요?", createdAt: nil, updatedAt: nil, isDeleted: nil, isHidden: nil, posts: nil, didAnswer: false),
            .init(questionId: nil, content: "어린 시절 기억에 남는 순간이 있나요?", createdAt: nil, updatedAt: nil, isDeleted: nil, isHidden: nil, posts: nil, didAnswer: false),
            .init(questionId: nil, content: "어린 시절 기억에 남는 순간이 있나요?", createdAt: nil, updatedAt: nil, isDeleted: nil, isHidden: nil, posts: nil, didAnswer: true),
            .init(questionId: nil, content: "어린 시절 기억에 남는 순간이 있나요?", createdAt: nil, updatedAt: nil, isDeleted: nil, isHidden: nil, posts: nil, didAnswer: true),
            .init(questionId: nil, content: "어린 시절 기억에 남는 순간이 있나요?", createdAt: nil, updatedAt: nil, isDeleted: nil, isHidden: nil, posts: nil, didAnswer: false),
            .init(questionId: nil, content: "어린 시절 기억에 남는 순간이 있나요?", createdAt: nil, updatedAt: nil, isDeleted: nil, isHidden: nil, posts: nil, didAnswer: false),
        ]
    ))
}
