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
        cellFactory = VSleekStreamCellFactory(dependencyManager: dependencyManager)
    }
    
    // MARK: - Dependency manager
    
    var dependencyManager: VDependencyManager!
    
    // MARK: - Models
    
    var user: VUser? {
        didSet {
            unload()
            
            if let user = user {
                stream = VStreamItem.userProfileStreamWithUserID(user.remoteId)
            }
            else {
                stream = nil
            }
        }
    }
    
    private var stream: VStream?
    
    // MARK: - Cell factory
    
    private let cellFactory: VSleekStreamCellFactory
    
    // MARK: - Registering views
    
    func registerViewsFor(collectionView: UICollectionView) {
        let headerNib = UINib(nibName: "VNewProfileHeaderView", bundle: nil)
        collectionView.registerNib(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ProfileHeaderView")
        
        cellFactory.registerCellsWithCollectionView(collectionView)
    }
    
    // MARK: - Loading content
    
    func loadStreamItems(pageType: VPageType, completion: ((error: NSError?) -> Void)? = nil) {
        guard let apiPath = stream?.apiPath else {
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
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ProfileHeaderView", forIndexPath: indexPath) as! VNewProfileHeaderView
        headerView.dependencyManager = dependencyManager
        headerView.user = user
        return headerView
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return cellFactory.collectionView(collectionView, cellForStreamItem: visibleItems[indexPath.row] as! VStreamItem, atIndexPath: indexPath, inStream: stream)
    }
}
