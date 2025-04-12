//
//  QuestionRepositoryProtocol.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation

protocol QuestionRepositoryProtocol {
    func getAll() async throws -> [Question]
}
