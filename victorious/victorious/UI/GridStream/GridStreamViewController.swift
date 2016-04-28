//
//  GridStreamViewController.swift
//  victorious
//
//  Created by Vincent Ho on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class GridStreamViewController<HeaderType: ConfigurableGridStreamHeader>: UIViewController, ConfigurableGridStreamCollectionView, VPaginatedDataSourceDelegate, VScrollPaginatorDelegate, VBackgroundContainer {
    
    private let defaultCellSpacing: CGFloat = 10.0
    
    // MARK: Variables
    
    private let dependencyManager: VDependencyManager
    private let collectionView = UICollectionView(frame: CGRectZero,
                                                  collectionViewLayout: UICollectionViewFlowLayout())
    private let refreshControl = UIRefreshControl()
    
    private let dataSource: GridStreamDataSource<HeaderType>
    private let delegate: GridStreamDelegateFlowLayout<HeaderType>
    private let scrollPaginator = VScrollPaginator()
    
    // MARK: - Initializing
    
    static func newWithDependencyManager(
        dependencyManager: VDependencyManager,
        header: HeaderType? = nil,
        content: HeaderType.ContentType) -> GridStreamViewController {
        
        return GridStreamViewController(
            dependencyManager: dependencyManager,
            header: header,
            content: content)
    }
    
    private init(dependencyManager: VDependencyManager,
                 header: HeaderType? = nil,
                 content: HeaderType.ContentType) {
        
        self.dependencyManager = dependencyManager
        
        delegate = GridStreamDelegateFlowLayout<HeaderType>(
            dependencyManager: dependencyManager,
            header: header,
            content: content)
        
        dataSource = GridStreamDataSource<HeaderType>(
            dependencyManager: dependencyManager,
            header: header,
            content: content)
        
        super.init(nibName: nil, bundle: nil)
        
        delegate.configurableViewController = self
        
        self.dependencyManager.addBackgroundToBackgroundHost(self)
        collectionView.backgroundColor = UIColor.clearColor()
        
        dataSource.delegate = self
        dataSource.registerViewsFor(collectionView)
        
        collectionView.delegate = delegate
        collectionView.dataSource = dataSource
        collectionView.backgroundColor = nil
        collectionView.alwaysBounceVertical = true
        
        collectionView.registerNib(
            VFooterActivityIndicatorView.nibForSupplementaryView(),
            forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
            withReuseIdentifier: VFooterActivityIndicatorView.reuseIdentifier()
        )
        
        scrollPaginator.delegate = self
        
        edgesForExtendedLayout = .Bottom
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
        dependencyManager.addBackgroundToBackgroundHost(self)
        
        view.addSubview(collectionView)
        view.v_addFitToParentConstraintsToSubview(collectionView)
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let spacing = defaultCellSpacing // TODO: Configurable
            flowLayout.minimumInteritemSpacing = spacing
            flowLayout.sectionInset = UIEdgeInsets(
                top: 0.0,
                left: spacing,
                bottom: spacing,
                right: spacing)
        }
        
        refreshControl.tintColor = dependencyManager.refreshControlColor
        refreshControl.addTarget(
            self,
            action: #selector(GridStreamViewController.refresh),
            forControlEvents: .ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
        dataSource.loadStreamItems(.First)
    }
    
    // MARK: - Refreshing
    
    func refresh() {
        dataSource.loadStreamItems(.First) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - Configuration
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait]
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollPaginator.scrollViewDidScroll(scrollView)
    }
    
    // MARK: - VPaginatedDataSourceDelegate
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource,
                             didUpdateVisibleItemsFrom oldValue: NSOrderedSet,
                             to newValue: NSOrderedSet) {
        collectionView.v_applyChangeInSection(0, from: oldValue, to: newValue, animated: false)
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource,
                             didChangeStateFrom oldState: VDataSourceState,
                             to newState: VDataSourceState) {
        if oldState == .Loading {
            refreshControl.endRefreshing()
        }
        
        if newState == .Loading || oldState == .Loading {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource,
                             didReceiveError error: NSError) {
        (navigationController ?? self).v_showErrorDefaultError()
    }
    
    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() {
        dataSource.loadStreamItems(.Next)
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return view
    }
    
    // MARK: - ConfigurableHeaderCollectionView
    
    func willDisplaySupplementaryView(footerView: VFooterActivityIndicatorView) {
        footerView.activityIndicator.color = dependencyManager.refreshControlColor
        footerView.setActivityIndicatorVisible(dataSource.isLoading(), animated: true)
    }
}

private extension VDependencyManager {
    var refreshControlColor: UIColor? {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
}

