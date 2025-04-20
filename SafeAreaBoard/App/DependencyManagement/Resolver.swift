//
//  Dependency.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/20/25.
//

import Foundation
import Swinject

struct Resolver<T> {
    static func resolve(
        name: String? = nil,
        in containerType: ContainerType = .shared,
        afterInitialization: ((_ resolved: T) -> Void)? = nil
    ) -> T {
        let container = containerType.getContainer()
        
        if let resolved =
            name == nil
            ? container.resolve(T.self)
            : container.resolve(T.self, name: name) {
            
            afterInitialization?(resolved)
            
            return resolved
        } else {
            fatalError("no component resolved for \(T.self)")
        }
    }
    
    enum ContainerType {
        case shared
        case custom(Container)
        
        func getContainer() -> Container {
            switch self {
            case .shared:
                return DIContainerProvider.shared.container
            case .custom(let container):
                return container
            }
        }
    }
}
