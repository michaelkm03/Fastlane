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
    
    fileprivate(set) var visibleItems: [UserModel] = [] {
        didSet {
            state = visibleItems.isEmpty ? .noContent : .items
            delegate?.didUpdateVisibleItems(forSection: .creator)
        }
    }

    fileprivate(set) var state: ListMenuDataSourceState = .loading
    
    weak var delegate: ListMenuSectionDataSourceDelegate?
    
    func fetchRemoteData(success: FetchRemoteDataCallback?) {
        guard
            let apiPath = dependencyManager.creatorListAPIPath,
            let request = CreatorListRequest(apiPath: apiPath)
        else {
            Log.info("Missing or invalid creator list API path: \(dependencyManager.creatorListAPIPath)")
            return
        }
        
        RequestOperation(request: request).queue { [weak self] result in
            switch result {
                case .success(let users):
                    self?.visibleItems = users
                    success?()
                case .failure(let error):
                    self?.state = .failed(error: error)
                    self?.delegate?.didUpdateVisibleItems(forSection: .creator)
                case .cancelled:
                    break
            }
        }
    }
}

private extension VDependencyManager {
    var creatorListAPIPath: APIPath? {
        return apiPath(forKey: "listOfCreatorsURL")
    }
}
