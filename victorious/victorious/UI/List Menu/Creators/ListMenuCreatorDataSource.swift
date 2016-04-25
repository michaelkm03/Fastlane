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
            delegate?.didUpdateVisibleItems(forSection: .creator)
        }
    }
    
    weak var delegate: ListMenuSectionDataSourceDelegate?
    
    func fetchRemoteData() {
        let operation = TrendingUsersOperation()
        operation.queue() { [weak self] results, error, cancelled in
            guard let users = results as? [VUser] else {
                return
            }
            self?.visibleItems = users
        }
    }
}
