//
//  QuestionWithAnswerStatus.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/13/25.
//

import Foundation

struct QuestionWithAnswerStatus {
    let questionId: Int?
    let content: String?
    let createdAt: Date?
    let updatedAt: Date?
    let isDeleted: Bool?
    let isHidden: Bool?
    let posts: [Post]?
    let didAnswer: Bool
    
    init(questionId: Int?, content: String?, createdAt: Date?, updatedAt: Date?, isDeleted: Bool?, isHidden: Bool?, posts: [Post]?, didAnswer: Bool) {
        self.questionId = questionId
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDeleted = isDeleted
        self.isHidden = isHidden
        self.posts = posts
        self.didAnswer = didAnswer
    }
    
    init(question: Question, didAnswer: Bool) {
        self.questionId = question.questionId
        self.content = question.content
        self.createdAt = question.createdAt
        self.updatedAt = question.updatedAt
        self.isDeleted = question.isDeleted
        self.isHidden = question.isHidden
        self.posts = question.posts
        self.didAnswer = didAnswer
    }
}
