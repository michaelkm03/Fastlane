//
//  TutorialNetworkDataSource.swift
//  victorious
//
//  Created by Tian Lan on 5/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Conformers can respond to the results fetched by this network data source
protocol TutorialNetworkDataSourceDelegate: class {
    func didUpdateVisibleItems(from oldValue: [ChatMessageType], to newValue: [ChatMessageType])
    func didFinishFetchingAllItems()
}

class TutorialNetworkDataSource: NetworkDataSource {
    private(set) var visibleItems: [ChatMessageType] = [] {
        didSet {
            delegate?.didUpdateVisibleItems(from: oldValue, to: visibleItems)
        }
    }
    
    weak var delegate: TutorialNetworkDataSourceDelegate?
    
    private let dependencyManager: VDependencyManager
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        
        dispatch_after(1.0) { [weak self] in
            self?.delegate?.didFinishFetchingAllItems()
        }
    }
}
