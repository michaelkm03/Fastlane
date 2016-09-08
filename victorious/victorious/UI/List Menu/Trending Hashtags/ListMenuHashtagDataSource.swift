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
    private(set) var visibleItems: [Hashtag] = [] {
        didSet {
            state = visibleItems.isEmpty ? .noContent : .items
            delegate?.didUpdateVisibleItems(forSection: .hashtags)
        }
    }
    
    private(set) var state: ListMenuDataSourceState = .loading
    
    weak var delegate: ListMenuSectionDataSourceDelegate?
    
    func fetchRemoteData() {
        guard let trendingHashtagsURL = dependencyManager.trendingHashtagsURL else {
            return
        }
        
        let operation = RequestOperation(
            request: TrendingHashtagRequest(url: trendingHashtagsURL)
        )
        
        operation.queue { [weak self] result in
            switch result {
                case .success(let hashtags):
                    self?.visibleItems = hashtags
                
                case .failure(let error):
                    self?.state = .failed(error: error)
                    self?.delegate?.didUpdateVisibleItems(forSection: .hashtags)
                
                case .cancelled:
                    self?.delegate?.didUpdateVisibleItems(forSection: .hashtags)
            }
        }
    }
}

private extension VDependencyManager {
    var trendingHashtagsURL: NSURL? {
        guard let urlString = networkResources?.stringForKey("trendingHashtagsURL") else {
            return nil
        }
        return NSURL(string: urlString)
    }
}
