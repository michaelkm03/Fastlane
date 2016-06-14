//
//  ListMenuHashtagDataSource.swift
//  victorious
//
//  Created by Tian Lan on 4/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

final class ListMenuHashtagDataSource: ListMenuSectionDataSource {
    
    typealias Cell = ListMenuHashtagCollectionViewCell

    // MARK: - Initialization
    
    /// Initializes a ListMenuHashtagDataSource, then start to fetch trending hashtags from backend
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        
        fetchRemoteData()
    }
    
    // MARK - Dependency manager
    
    let dependencyManager: VDependencyManager
    
    var hashtagStreamAPIPath: APIPath {
        return dependencyManager.apiPathForKey("streamURL") ?? APIPath(templatePath: "")
    }
    
    // MARK: - List Menu Section Data Source
    
    /// An array of visible hashtags. This array starts with no hashtags,
    /// and gets populated after `fetchRemoteData` is called
    private(set) var visibleItems: [HashtagSearchResultObject] = [] {
        didSet {
            state = visibleItems.isEmpty ? .noContent : .items
            delegate?.didUpdateVisibleItems(forSection: .hashtags)
        }
    }
    
    private(set) var state: ListMenuDataSourceState = .loading
    
    weak var delegate: ListMenuSectionDataSourceDelegate?
    
    func fetchRemoteData() {
        let operation = TrendingHashtagOperation()
        operation.queue { [weak self] results, error, cancelled in
            guard let hashtags = results as? [HashtagSearchResultObject] else {
                self?.state = .failed(error: error)
                return
            }
            self?.visibleItems = hashtags
        }
    }
}
