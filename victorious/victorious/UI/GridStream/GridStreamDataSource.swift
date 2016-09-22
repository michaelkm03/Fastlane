//
//  ConfigurableHeaderContentStreamDataSource.swift
//  victorious
//
//  Created by Vincent Ho on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

enum GridStreamSection: Int {
    case Header = 0
    case Contents
}

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
        
        paginatedDataSource = TimePaginatedDataSource(
            apiPath: streamAPIPath,
            createOperation: { ContentFeedOperation(apiPath: $0, payloadType: .lightweight) },
            processOutput: { $0.contents }
        )
    }
    
    // MARK: - Dependency manager
    
    private let dependencyManager: VDependencyManager
    private var gridDependency: VDependencyManager
    
    // MARK: - Registering views
    
    func registerViewsFor(collectionView: UICollectionView) {
        let headerNib = UINib(nibName: headerName, bundle: nil)
        collectionView.registerNib(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerName)
        CollectionLoadingView.register(in: collectionView, forSupplementaryViewKind: UICollectionElementKindSectionFooter)
    }
    
    // MARK: - Managing content
    
    private(set) var content: HeaderType.ContentType?
    private var hasError = false
    
    func setContent(content: HeaderType.ContentType?, withError hasError: Bool) {
        self.content = content
        self.hasError = hasError
    }
    
    // MARK: - Managing items
    
    private let paginatedDataSource: TimePaginatedDataSource<Content, ContentFeedOperation>
    
    var items: [Content] {
        return paginatedDataSource.items
    }
    
    var isLoading: Bool {
        return paginatedDataSource.isLoading
    }
    
    var hasLoadedAllItems: Bool {
        return !paginatedDataSource.olderItemsAreAvailable
    }
    
    func loadContent(for collectionView: UICollectionView, loadingType: PaginatedLoadingType, completion: ((result: Result<[Content]>) -> Void)? = nil) {
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
            else if let totalItemCount = self?.items.count where newItems.count > 0 {
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
    
    private let cellFactory: VContentOnlyCellFactory
    private var headerView: ConfigurableGridStreamHeaderView!
    private var header: HeaderType?

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let gridStreamSection = GridStreamSection(rawValue: section) else {
            return 0
        }
        
        switch gridStreamSection {
            case .Header:
                return 0
            case .Contents:
                return items.count
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter && indexPath.section == GridStreamSection.Contents.rawValue {
            return CollectionLoadingView.dequeue(from: collectionView, forSupplementaryViewKind: kind, at: indexPath)
        }
        else if kind == UICollectionElementKindSectionHeader && indexPath.section == GridStreamSection.Header.rawValue {
            if headerView == nil {
                headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: headerName, forIndexPath: indexPath) as? ConfigurableGridStreamHeaderView
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
