//
//  ListMenuCreatorDataSource.swift
//  victorious
//
//  Created by Tian Lan on 4/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class ListMenuCreatorDataSource: ListMenuSectionDataSource {
    typealias Cell = ListMenuCreatorCollectionViewCell
    
    let dependencyManager: VDependencyManager
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
    
    // MARK: - List Menu Section Data Source
    
    private(set) var visibleItems: [VUser] = [] {
        didSet {
            state = visibleItems.isEmpty ? .noContent : .items
            delegate?.didUpdateVisibleItems(forSection: .creator)
        }
    }

    private(set) var state: ListMenuDataSourceState = .loading
    
    weak var delegate: ListMenuSectionDataSourceDelegate?
    
    func fetchRemoteData() {
        let endpointURLFromTemplate = dependencyManager.listOfCreatorsURLString
        let operation = CreatorListOperation(urlString: endpointURLFromTemplate)
        operation.queue() { [weak self] results, error, cancelled in
            guard let users = results as? [VUser] else {
                self?.state = .failed(error: error)
                return
            }
            self?.visibleItems = users
        }
    }
}

private extension VDependencyManager {
    var listOfCreatorsURLString: String? {
        return stringForKey("listOfCreatorsURL")
    }
}
