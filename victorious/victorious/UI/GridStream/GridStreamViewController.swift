//
//  GridStreamViewController.swift
//  victorious
//
//  Created by Vincent Ho on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

struct GridStreamConfiguration {
    var sectionInset = UIEdgeInsetsMake(3, 0, 3, 0)
    var interItemSpacing = CGFloat(3)
    var cellsPerRow = 3
    var allowsForRefresh = true
}

class GridStreamViewController<HeaderType: ConfigurableGridStreamHeader>: UIViewController, UICollectionViewDelegateFlowLayout, VPaginatedDataSourceDelegate, VScrollPaginatorDelegate, VBackgroundContainer {
    
    // MARK: Variables
    
    let dependencyManager: VDependencyManager
    let collectionView = UICollectionView(frame: CGRectZero,
                                          collectionViewLayout: UICollectionViewFlowLayout())
    let dataSource: GridStreamDataSource<HeaderType>
    var content: HeaderType.ContentType? {
        didSet {
            dataSource.content = content
        }
    }
    
    private let refreshControl = UIRefreshControl()
    
    private let scrollPaginator = VScrollPaginator()
    private let configuration: GridStreamConfiguration
    
    private var header: HeaderType?
    
    // MARK: - Initializing
    
    static func newWithDependencyManager(
        dependencyManager: VDependencyManager,
        header: HeaderType? = nil,
        content: HeaderType.ContentType,
        configuration: GridStreamConfiguration? = nil,
        streamAPIPath: String) -> GridStreamViewController {
        
        return GridStreamViewController(
            dependencyManager: dependencyManager,
            header: header,
            content: content,
            configuration: configuration,
            streamAPIPath: streamAPIPath)
    }
    
    init(dependencyManager: VDependencyManager,
                 header: HeaderType? = nil,
                 content: HeaderType.ContentType?,
                 configuration: GridStreamConfiguration? = nil,
                 streamAPIPath: String) {
        
        self.dependencyManager = dependencyManager
        self.header = header
        self.content = content
        self.configuration = configuration ?? GridStreamConfiguration()
        
        dataSource = GridStreamDataSource<HeaderType>(
            dependencyManager: dependencyManager,
            header: header,
            content: content,
            streamAPIPath: streamAPIPath)
        
        super.init(nibName: nil, bundle: nil)
        
        self.dependencyManager.addBackgroundToBackgroundHost(self)
        
        dataSource.delegate = self
        dataSource.registerViewsFor(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
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
            flowLayout.minimumInteritemSpacing = self.configuration.interItemSpacing
            flowLayout.sectionInset = self.configuration.sectionInset
            flowLayout.minimumLineSpacing = self.configuration.interItemSpacing
        }
        
        if self.configuration.allowsForRefresh {
            refreshControl.tintColor = dependencyManager.refreshControlColor
            refreshControl.addTarget(
                self,
                action: #selector(GridStreamViewController.refresh),
                forControlEvents: .ValueChanged
            )
            collectionView.insertSubview(refreshControl, atIndex: 0)
        }
        
        dataSource.loadStreamItems(.First)
    }
    
    override func viewWillAppear(animated: Bool) {
        dependencyManager.applyStyleToNavigationBar(navigationController?.navigationBar)
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
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollPaginator.scrollViewDidScroll(scrollView)
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return view
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        guard let header = header,
            content = content else {
            return CGSizeZero
        }
        let size = header.sizeForHeader(
            dependencyManager,
            maxHeight: CGRectGetHeight(collectionView.bounds),
            content: content
        )
        return size
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        return flowLayout.v_cellSize(
            fittingWidth: collectionView.bounds.width,
            cellsPerRow: configuration.cellsPerRow
        )
    }
    
    func collectionView(collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        atIndexPath indexPath: NSIndexPath) {
        if let footerView = view as? VFooterActivityIndicatorView {
            footerView.activityIndicator.color = dependencyManager.refreshControlColor
            footerView.setActivityIndicatorVisible(dataSource.isLoading(), animated: true)
        }
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return dataSource.isLoading() ? VFooterActivityIndicatorView.desiredSizeWithCollectionViewBounds(collectionView.bounds) : CGSizeZero
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let seq = dataSource.visibleItems[indexPath.row] as! VSequence
        ShowCloseUpOperation(
            originViewController: self,
            dependencyManager: dependencyManager,
            sequence: seq
        ).queue()
    }
}

private extension VDependencyManager {
    var refreshControlColor: UIColor? {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
}
