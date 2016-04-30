//
//  ConfigurableHeaderContentStreamDataSource.swift
//  victorious
//
//  Created by Vincent Ho on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

private let headerName = "ConfigurableGridStreamHeaderView"

class GridStreamDataSource<HeaderType: ConfigurableGridStreamHeader>: PaginatedDataSource, UICollectionViewDataSource {
    private var apiPath: String!
    private var headerView: ConfigurableGridStreamHeaderView!
    private var header: HeaderType?
    private let dependencyManager: VDependencyManager
    private let cellFactory: VContentOnlyCellFactory
    private var content: HeaderType.ContentType {
        didSet {
            unload()
        }
    }
    
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager,
         header: HeaderType? = nil,
         content: HeaderType.ContentType,
         streamApiPath: String) {
        self.dependencyManager = dependencyManager
        self.header = header
        self.content = content
        apiPath = streamApiPath
        
        cellFactory = VContentOnlyCellFactory(dependencyManager: dependencyManager)
    }
    
    // MARK: - Registering views
    
    func registerViewsFor(collectionView: UICollectionView) {
        cellFactory.registerCellsWithCollectionView(collectionView)
        
        let headerNib = UINib(nibName: headerName, bundle: nil)
        collectionView.registerNib(headerNib,
                                   forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                   withReuseIdentifier: headerName)
    }
    
    // MARK: - Loading content
    
    func loadStreamItems(pageType: VPageType, completion: ((error: NSError?) -> Void)? = nil) {
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
    
    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return visibleItems.count
    }
    
    func collectionView(collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: VFooterActivityIndicatorView.reuseIdentifier(), forIndexPath: indexPath) as! VFooterActivityIndicatorView
        }
        else {
            if headerView != nil {
                return headerView
            }
            headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                                                               withReuseIdentifier: headerName,
                                                                               forIndexPath: indexPath) as? ConfigurableGridStreamHeaderView
            header?.decorateHeader(dependencyManager,
                                   maxHeight: CGRectGetHeight(collectionView.bounds),
                                   content: content)
            
            guard let header = header as? UIView else {
                assertionFailure("header is not a UIView")
                return headerView
            }
            headerView.addHeader(header)
            return headerView
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = cellFactory.collectionView(collectionView, cellForStreamItem: visibleItems[indexPath.row] as! VStreamItem, atIndexPath: indexPath)
        cell.layer.cornerRadius = 10
        cell.backgroundColor = .clearColor()
        cell.contentView.backgroundColor = .clearColor()
        return cell
    }
}
