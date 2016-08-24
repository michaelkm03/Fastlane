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
    
    private(set) var visibleItems: [UserModel] = [] {
        didSet {
            state = visibleItems.isEmpty ? .noContent : .items
            delegate?.didUpdateVisibleItems(forSection: .creator)
        }
    }

    private(set) var state: ListMenuDataSourceState = .loading
    
    weak var delegate: ListMenuSectionDataSourceDelegate?
    
    func fetchRemoteData() {
        guard let endpointURLFromTemplate = dependencyManager.listOfCreatorsURLString else {
            Log.info("nil endpoint url for list of creators on left nav")
            return
        }
        
        let operation = CreatorListRemoteOperation(urlString: endpointURLFromTemplate)
        
        operation.queue { [weak self] _, error, _ in
            guard error == nil else {
                self?.state = .failed(error: error)
                self?.delegate?.didUpdateVisibleItems(forSection: .creator)
                return
            }
            self?.visibleItems = operation.creators
        }
    }
}

private extension VDependencyManager {
    var listOfCreatorsURLString: String? {
        return stringForKey("listOfCreatorsURL")
    }
}
