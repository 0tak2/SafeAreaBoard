//
//  DIContainerEnvironment.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/11/25.
//

import Foundation
import Swinject
import os.log

final class DIContainerEnvironment: ObservableObject {
    private let containerProvider: DIContainerProvider
    private let log = Logger.of("DIContainerEnvironment")
    
    init(containerProvider: DIContainerProvider = .shared) {
        self.containerProvider = containerProvider
    }
    
    func resolve<Component>(_ type: Component.Type, name: String? = nil) -> Component? {
        log.info("try to resolve type=\(type) name=\(name ?? "")")
        return containerProvider.container.resolve(type, name: name)
    }
}
