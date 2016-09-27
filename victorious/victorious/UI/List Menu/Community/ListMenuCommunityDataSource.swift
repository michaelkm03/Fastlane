//
//  ListMenuCommunityDataSource.swift
//  victorious
//
//  Created by Tian Lan on 4/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

final class ListMenuCommunityDataSource: ListMenuSectionDataSource {
    
    typealias Cell = ListMenuCommunityCollectionViewCell

    let dependencyManager: VDependencyManager
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
    
    // MARK: - List Menu Section Data Source
    
    private(set) var visibleItems: [ListMenuCommunityItem] = [] {
        didSet {
            state = visibleItems.isEmpty ? .noContent : .items
            delegate?.didUpdateVisibleItems(forSection: .community)
        }
    }
    
    private(set) var state: ListMenuDataSourceState = .loading
    
    weak var delegate: ListMenuSectionDataSourceDelegate?
    
    func fetchRemoteData(success success: FetchRemoteDataCallback?) {
        guard let dependencies = dependencyManager.childDependencies(for: "items") else {
            state = .failed(error: NSError(domain: "ListMenuCommunityDataSource", code: 1, userInfo: nil))
            delegate?.didUpdateVisibleItems(forSection: .community)
            return
        }
        visibleItems = dependencies.flatMap { ListMenuCommunityItem($0) }
        success?()
    }
}
