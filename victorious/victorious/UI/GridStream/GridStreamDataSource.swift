//
//  ConfigurableHeaderContentStreamDataSource.swift
//  victorious
//
//  Created by Vincent Ho on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit


class GridStreamDataSource<HeaderType: ConfigurableGridStreamHeader>: NSObject, UICollectionViewDataSource {

    private let headerName = "ConfigurableGridStreamHeaderView"
    private let cellCornerRadius = CGFloat(6)
    private let cellBackgroundColor = UIColor.clearColor()
    private let cellContentBackgroundColor = UIColor.clearColor()

    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager, header: HeaderType? = nil, content: HeaderType.ContentType?, streamAPIPath: APIPath) {
        var streamAPIPath = streamAPIPath
        
        self.dependencyManager = dependencyManager
        self.gridDependency = dependencyManager.gridDependency
        self.header = header
        self.content = content
        self.cellFactory = VContentOnlyCellFactory(dependencyManager: gridDependency)
        
        streamAPIPath.queryParameters["filter_text"] = "true"
        
        paginatedDataSource = TimePaginatedDataSource(apiPath: streamAPIPath) {
            ContentFeedOperation(url: $0)
        }
    }
    
    // MARK: - Dependency manager
    
    private let dependencyManager: VDependencyManager
    private var gridDependency: VDependencyManager
    
    // MARK: - Registering views
    
    func registerViewsFor(collectionView: UICollectionView) {
        let headerNib = UINib(nibName: headerName, bundle: nil)
        collectionView.registerNib(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerName)
    }
    
    // MARK: - Managing content
    
    private(set) var content: HeaderType.ContentType?
    private var hasError = false
    
    func setContent(content: HeaderType.ContentType?, withError hasError: Bool) {
        self.content = content
        self.hasError = hasError
    }
    
    // MARK: - Managing items
    
    private let paginatedDataSource: TimePaginatedDataSource<ContentModel, ContentFeedOperation>
    
    var items: [ContentModel] {
        return paginatedDataSource.items
    }
    
    var isLoading: Bool {
        return paginatedDataSource.isLoading
    }
    
    func loadContent(for collectionView: UICollectionView, loadingType: PaginatedLoadingType, completion: ((newItems: [ContentModel], error: NSError?) -> Void)? = nil) {
        paginatedDataSource.loadItems(loadingType) { [weak self] newItems, stageEvent, error in
            if let items = self?.paginatedDataSource.items {
                self?.header?.gridStreamDidUpdateDataSource(with: items)
            }
            
            collectionView.collectionViewLayout.invalidateLayout()
            
            if loadingType == .refresh {
                collectionView.reloadData()
            }
            else if let totalItemCount = self?.items.count where newItems.count > 0 {
                let previousCount = totalItemCount - newItems.count
                
                let indexPaths = (0 ..< newItems.count).map {
                    NSIndexPath(forItem: previousCount + $0, inSection: 0)
                }
                
                collectionView.insertItemsAtIndexPaths(indexPaths)
            }
            
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
        }
        else {
            if headerView == nil {
                headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: headerName, forIndexPath: indexPath) as? ConfigurableGridStreamHeaderView
            }
            header?.decorateHeader(dependencyManager, maxHeight: CGRectGetHeight(collectionView.bounds), content: content, hasError: hasError)
            
            guard let header = header as? UIView else {
                assertionFailure("header is not a UIView")
                return headerView
            }
            headerView.addHeader(header)
            return headerView
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = cellFactory.collectionView( collectionView, cellForContent: items[indexPath.row], atIndexPath: indexPath)
        cell.layer.cornerRadius = cellCornerRadius
        cell.backgroundColor = cellBackgroundColor
        cell.contentView.backgroundColor = cellContentBackgroundColor
        return cell
    }
}

private extension VDependencyManager {
    var gridDependency: VDependencyManager {
        return childDependencyForKey("gridStream") ?? self
    }
}
