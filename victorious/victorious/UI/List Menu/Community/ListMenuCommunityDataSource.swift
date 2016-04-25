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
            delegate?.didUpdateVisibleItems(forSection: .community)
        }
    }
    
    weak var delegate: ListMenuSectionDataSourceDelegate?
    
    func fetchRemoteData() {
        guard let dependencies = dependencyManager.arrayForKey("items") as? [[String: AnyObject]] else {
            return
        }
        visibleItems = dependencies.flatMap { ListMenuCommunityItem($0) }
    }
}
