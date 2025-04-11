//
//  BaseProtocol.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/10/25.
//

import Foundation

protocol UseCase {
    associatedtype Command
    associatedtype Result
    
    func execute(command: Command) async throws -> Result
}
