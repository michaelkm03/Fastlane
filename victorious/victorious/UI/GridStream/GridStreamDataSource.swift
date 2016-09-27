//
//  ConfigurableHeaderContentStreamDataSource.swift
//  victorious
//
//  Created by Vincent Ho on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

enum GridStreamSection: Int {
    case header = 0
    case contents
}

class GridStreamDataSource<HeaderType: ConfigurableGridStreamHeader>: NSObject, UICollectionViewDataSource {

    fileprivate let headerName = "ConfigurableGridStreamHeaderView"
    fileprivate let cellCornerRadius = CGFloat(6)
    fileprivate let cellBackgroundColor = UIColor.clear
    fileprivate let cellContentBackgroundColor = UIColor.clear

    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager, header: HeaderType? = nil, content: HeaderType.ContentType?, streamAPIPath: APIPath) {
        var streamAPIPath = streamAPIPath
        
        self.dependencyManager = dependencyManager
        self.gridDependency = dependencyManager.gridDependency
        self.header = header
        self.content = content
        self.cellFactory = VContentOnlyCellFactory(dependencyManager: gridDependency)
        
        streamAPIPath.queryParameters["filter_text"] = "true"
        
        paginatedDataSource = TimePaginatedDataSource(
            apiPath: streamAPIPath,
            createOperation: { ContentFeedOperation(apiPath: $0, payloadType: .lightweight) },
            processOutput: { $0.contents }
        )
    }
    
    // MARK: - Dependency manager
    
    fileprivate let dependencyManager: VDependencyManager
    fileprivate var gridDependency: VDependencyManager
    
    // MARK: - Registering views
    
    func registerViewsFor(_ collectionView: UICollectionView) {
        let headerNib = UINib(nibName: headerName, bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerName)
        CollectionLoadingView.register(in: collectionView, forSupplementaryViewKind: UICollectionElementKindSectionFooter)
    }
    
    // MARK: - Managing content
    
    fileprivate(set) var content: HeaderType.ContentType?
    fileprivate var hasError = false
    
    func setContent(_ content: HeaderType.ContentType?, withError hasError: Bool) {
        self.content = content
        self.hasError = hasError
    }
    
    // MARK: - Managing items
    
    fileprivate let paginatedDataSource: TimePaginatedDataSource<Content, ContentFeedOperation>
    
    var items: [Content] {
        return paginatedDataSource.items
    }
    
    var isLoading: Bool {
        return paginatedDataSource.isLoading
    }
    
    var hasLoadedAllItems: Bool {
        return !paginatedDataSource.olderItemsAreAvailable
    }
    
    func loadContent(for collectionView: UICollectionView, loadingType: PaginatedLoadingType, completion: ((_ result: Result<[Content]>) -> Void)? = nil) {
        paginatedDataSource.loadItems(loadingType) { [weak self] result in
            if let items = self?.paginatedDataSource.items {
                self?.header?.gridStreamDidUpdateDataSource(with: items)
            }
            
            let newItems: [Content]
            
            switch result {
                case .success(let feedResult): newItems = feedResult.contents
                case .failure(_), .cancelled: newItems = []
            }
            
            if loadingType == .refresh {
                // Reloading the non-header section
                // Also, collectionView.reloadData() was not properly reloading the cells.
                let desiredSection = GridStreamSection.Contents.rawValue
                if collectionView.numberOfSections() > desiredSection {
                    collectionView.reloadSections(NSIndexSet(index: desiredSection))
                }
            }
            else if let totalItemCount = self?.items.count , newItems.count > 0 {
                collectionView.collectionViewLayout.invalidateLayout()

                let previousCount = totalItemCount - newItems.count
                
                let indexPaths = (0 ..< newItems.count).map {
                    NSIndexPath(forItem: previousCount + $0, inSection: GridStreamSection.Contents.rawValue)
                }
                
                collectionView.insertItemsAtIndexPaths(indexPaths)
            }
            
            switch result {
                case .success(let feedResult): completion?(result: .success(feedResult.contents))
                case .failure(let error): completion?(result: .failure(error))
                case .cancelled: completion?(result: .success([]))
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    fileprivate let cellFactory: VContentOnlyCellFactory
    fileprivate var headerView: ConfigurableGridStreamHeaderView!
    fileprivate var header: HeaderType?

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let gridStreamSection = GridStreamSection(rawValue: section) else {
            return 0
        }
        
        switch gridStreamSection {
            case .header:
                return 0
            case .contents:
                return items.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter && (indexPath as NSIndexPath).section == GridStreamSection.contents.rawValue {
            return CollectionLoadingView.dequeue(from: collectionView, forSupplementaryViewKind: kind, at: indexPath)
        }
        else if kind == UICollectionElementKindSectionHeader && (indexPath as NSIndexPath).section == GridStreamSection.header.rawValue {
            if headerView == nil {
                headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerName, for: indexPath) as? ConfigurableGridStreamHeaderView
            }
            header?.decorateHeader(dependencyManager,
                                   withWidth: collectionView.frame.width,
                                   maxHeight: collectionView.frame.height,
                                   content: content,
                                   hasError: hasError
            )
            
            guard let header = header as? UIView else {
                assertionFailure("header is not a UIView")
                return headerView
            }
            headerView.addHeader(header)
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
