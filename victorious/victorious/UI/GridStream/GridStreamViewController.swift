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
    var managesBackground = true
}

class GridStreamViewController<HeaderType: ConfigurableGridStreamHeader>: UIViewController, UICollectionViewDelegateFlowLayout, VScrollPaginatorDelegate, VBackgroundContainer {
    
    // MARK: Variables
    
    let dependencyManager: VDependencyManager
    private let collectionView = UICollectionView(
        frame: CGRectZero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    private let dataSource: GridStreamDataSource<HeaderType>
    var content: HeaderType.ContentType? {
        didSet {
            dataSource.content = content
            collectionView.reloadSections(NSIndexSet(index: 0))
        }
    }
    
    private let refreshControl = UIRefreshControl()
    
    private let scrollPaginator = VScrollPaginator()
    private let configuration: GridStreamConfiguration
    
    private var header: HeaderType?
    
    // MARK: - Initializing
    
    init(
        dependencyManager: VDependencyManager,
        header: HeaderType? = nil,
        content: HeaderType.ContentType?,
        configuration: GridStreamConfiguration? = nil,
        streamAPIPath: APIPath
    ) {
        self.dependencyManager = dependencyManager
        self.header = header
        self.content = content
        self.configuration = configuration ?? GridStreamConfiguration()
        
        dataSource = GridStreamDataSource<HeaderType>(
            dependencyManager: dependencyManager,
            header: header,
            content: content,
            streamAPIPath: streamAPIPath
        )
        
        super.init(nibName: nil, bundle: nil)
        
        dataSource.registerViewsFor(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.backgroundColor = UIColor.clearColor()
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
        
        if self.configuration.managesBackground {
            dependencyManager.addBackgroundToBackgroundHost(self)
        }
        
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
                action: #selector(refresh),
                forControlEvents: .ValueChanged
            )
            collectionView.insertSubview(refreshControl, atIndex: 0)
        }
        
        loadContent(.refresh)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - View events
    
    override func viewWillAppear(animated: Bool) {
        dependencyManager.applyStyleToNavigationBar(navigationController?.navigationBar)
    }
    
    // MARK: - Refreshing
    
    func refresh() {
        loadContent(.refresh)
    }
    
    private func loadContent(loadingType: PaginatedLoadingType) {        
        dataSource.loadContent(for: collectionView, loadingType: loadingType) { [weak self] newItems, error in
            // Calling this method stops scrolling, so only do it if necessary.
            if self?.refreshControl.refreshing == true {
                self?.refreshControl.endRefreshing()
            }
            
            if error != nil {
                (self?.navigationController ?? self)?.v_showErrorDefaultError()
            }
        }
    }
    
    // MARK: - Configuration
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait]
    }
    
    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() {
        loadContent(.older)
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
        
        guard let header = header else {
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
            footerView.setActivityIndicatorVisible(dataSource.isLoading, animated: true)
        }
        else if elementKind == UICollectionElementKindSectionHeader {
            header?.headerWillAppear()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        if elementKind == UICollectionElementKindSectionHeader {
            header?.headerDidDisappear()
        }
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return dataSource.isLoading ? VFooterActivityIndicatorView.desiredSizeWithCollectionViewBounds(collectionView.bounds) : CGSizeZero
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let displayModifier = ShowCloseUpDisplayModifier(dependencyManager: dependencyManager, originViewController: self)
        ShowCloseUpOperation.showOperation(forContentID: dataSource.items[indexPath.row].id!, displayModifier: displayModifier).queue()
    }
}

private extension VDependencyManager {
    var refreshControlColor: UIColor? {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
}
