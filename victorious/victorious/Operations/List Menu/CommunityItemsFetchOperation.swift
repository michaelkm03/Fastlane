//
//  CommunityItemsFetchOperation.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class CommunityItemsFetchOperation: SyncOperation<[ListMenuCommunityItem]> {
    private let dependencyManager: VDependencyManager

    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }

    override var executionQueue: Queue {
        return .background
    }

    override func execute() -> OperationResult<[ListMenuCommunityItem]> {
        guard let dependencies = dependencyManager.childDependencies(for: "items") else {
            let error = NSError(domain: "\(type(of: self))", code: 1, userInfo: nil)
            return .failure(error)
        }
        return .success(dependencies.flatMap { ListMenuCommunityItem($0) })
    }
}
