//
//  VNewProfileStreamDataSource.swift
//  victorious
//
//  Created by Jarod Long on 4/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VNewProfileStreamDataSource: PaginatedDataSource, UICollectionViewDataSource {
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        cellFactory = VContentOnlyCellFactory(dependencyManager: dependencyManager)
    }
    
    // MARK: - Dependency manager
    
    let dependencyManager: VDependencyManager
    
    // MARK: - Models
    
    var user: VUser? {
        didSet {
            unload()
        }
    }
    
    // MARK: - Cell factory
    
    private let cellFactory: VContentOnlyCellFactory
    
    // MARK: - Registering views
    
    func registerViewsFor(collectionView: UICollectionView) {
        let headerNib = UINib(nibName: "VNewProfileHeaderView", bundle: nil)
        collectionView.registerNib(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ProfileHeaderView")
        
        cellFactory.registerCellsWithCollectionView(collectionView)
    }
    
    // MARK: - Loading content
    
    func loadStreamItems(pageType: VPageType, completion: ((error: NSError?) -> Void)? = nil) {
        guard let user = user, apiPath = dependencyManager.streamAPIPath(for: user) else {
            completion?(error: NSError(domain: "StreamLoadingError", code: 1, userInfo: nil))
            return
        }
        
        loadPage(pageType,
            createOperation: {
                return StreamOperation(apiPath: apiPath)
            },
            completion: { results, error, cancelled in
                completion?(error: error)
            }
        )
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleItems.count
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: VFooterActivityIndicatorView.reuseIdentifier(), forIndexPath: indexPath) as! VFooterActivityIndicatorView
        }
        else {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ProfileHeaderView", forIndexPath: indexPath) as! VNewProfileHeaderView
            headerView.dependencyManager = dependencyManager
            headerView.user = user
            return headerView
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return cellFactory.collectionView(collectionView, cellForStreamItem: visibleItems[indexPath.row] as! VStreamItem, atIndexPath: indexPath)
    }
}

private extension VDependencyManager {
    func streamAPIPath(for user: VUser) -> String? {
        return stringForKey("streamURL")?.stringByReplacingOccurrencesOfString("%%USER_ID%%", withString: "\(user.remoteId.integerValue)")
    }
}
