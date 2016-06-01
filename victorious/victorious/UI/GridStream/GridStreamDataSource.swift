//
//  ConfigurableHeaderContentStreamDataSource.swift
//  victorious
//
//  Created by Vincent Ho on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

private let headerName = "ConfigurableGridStreamHeaderView"

class GridStreamDataSource<HeaderType: ConfigurableGridStreamHeader>: NSObject, UICollectionViewDataSource {
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager, header: HeaderType? = nil, content: HeaderType.ContentType?, streamAPIPath: APIPath) {
        self.dependencyManager = dependencyManager
        self.header = header
        self.content = content
        self.cellFactory = VContentOnlyCellFactory(dependencyManager: dependencyManager)
        
        paginatedDataSource = TimePaginatedDataSource(apiPath: streamAPIPath) {
            ContentFeedOperation(url: $0)
        }
    }
    
    // MARK: - Dependency manager
    
    private let dependencyManager: VDependencyManager
    
    // MARK: - Registering views
    
    func registerViewsFor(collectionView: UICollectionView) {
        cellFactory.registerCellsWithCollectionView(collectionView)
        
        let headerNib = UINib(nibName: headerName, bundle: nil)
        collectionView.registerNib(headerNib,
                                   forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                   withReuseIdentifier: headerName)
    }
    
    // MARK: - Managing content
    
    var content: HeaderType.ContentType?
    
    // MARK: - Managing items
    
    private let paginatedDataSource: TimePaginatedDataSource<ContentModel, ContentFeedOperation>
    
    var items: [ContentModel] {
        return paginatedDataSource.items
    }
    
    var isLoading: Bool {
        return paginatedDataSource.isLoading
    }
    
    func loadContent(loadingType: PaginatedLoadingType, completion: ((newItems: [ContentModel], error: NSError?) -> Void)? = nil) {
        paginatedDataSource.loadItems(loadingType) { [weak self] newItems, error in
            // TODO: Reload collection view data.
            completion?(newItems: newItems, error: error)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    private let cellFactory: VContentOnlyCellFactory
    private var headerView: ConfigurableGridStreamHeaderView!
    private var header: HeaderType?
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: VFooterActivityIndicatorView.reuseIdentifier(), forIndexPath: indexPath) as! VFooterActivityIndicatorView
        } else {
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
        let cell = cellFactory.collectionView(
            collectionView,
            cellForContent: items[indexPath.row],
            atIndexPath: indexPath
        )
        
        cell.layer.cornerRadius = 6
        cell.backgroundColor = .clearColor()
        cell.contentView.backgroundColor = .clearColor()
        return cell
    }
}
