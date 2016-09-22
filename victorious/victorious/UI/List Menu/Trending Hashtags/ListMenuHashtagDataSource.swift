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
    
    var hashtagStreamTrackingAPIPaths: [APIPath] {
        return dependencyManager.trackingAPIPaths(forEventKey: "view") ?? []
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
        guard
            let apiPath = dependencyManager.trendingHashtagsAPIPath,
            let request = TrendingHashtagRequest(apiPath: apiPath)
        else {
            Log.warning("Missing or invalid trending hashtags API path: \(dependencyManager.trendingHashtagsAPIPath)")
            return
        }
        
        RequestOperation(request: request).queue { [weak self] result in
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
    var trendingHashtagsAPIPath: APIPath? {
        return networkResources?.apiPathForKey("trendingHashtagsURL")
    }
}
