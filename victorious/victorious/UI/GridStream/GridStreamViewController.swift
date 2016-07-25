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

class GridStreamViewController<HeaderType: ConfigurableGridStreamHeader>: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, VScrollPaginatorDelegate, VBackgroundContainer, ContentCellTracker {
    
    // MARK: Variables
    
    let dependencyManager: VDependencyManager
    private let collectionView = UICollectionView(
        frame: CGRectZero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    private let dataSource: GridStreamDataSource<HeaderType>

    private(set) var content: HeaderType.ContentType?
    private var hasError: Bool = false
    
    func setContent(content: HeaderType.ContentType?, withError hasError: Bool) {
        self.content = content
        self.hasError = hasError
        updateTrackingParameters()
        dataSource.setContent(content, withError: hasError)
    }
    
    private let refreshControl = UIRefreshControl()
    
    private let scrollPaginator = VScrollPaginator()
    private let configuration: GridStreamConfiguration
    
    private var header: HeaderType?
    
    private var trackingParameters: [NSObject : AnyObject] = [:]
    
    // MARK: - ContentCellTracker
    
    var sessionParameters: [NSObject : AnyObject] {
        return trackingParameters
    }
    
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
        
        updateTrackingParameters()
        
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
    
    // MARK: - Refreshing
    
    func refresh() {
        loadContent(.refresh)
        header?.gridStreamShouldRefresh()
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
        
        guard
            section == 0,
            let header = header
        else {
            return CGSizeZero
        }
        
        let size = header.sizeForHeader(
            dependencyManager,
            maxHeight: CGRectGetHeight(collectionView.bounds),
            content: content,
            hasError: hasError
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
        guard section == 1 else {
            return CGSizeZero
        }
        
        return dataSource.isLoading ? VFooterActivityIndicatorView.desiredSizeWithCollectionViewBounds(collectionView.bounds) : CGSizeZero
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        let targetContent = dataSource.items[indexPath.row]
        let destination = DeeplinkDestination(content: targetContent)
        router.navigate(to: destination)
        header?.headerDidDisappear()
        
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ContentCell else {
            return
        }
        trackCell(cell, trackingKey: .cellClick)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? ContentCell else {
            return
        }
        
        trackCell(cell, trackingKey: .cellView)
    }
    
    // MARK: - Tracking updating
    
    private func updateTrackingParameters() {
        if
            let content = content as? ContentModel,
            let contentId = content.id
        {
            trackingParameters = [ VTrackingKeyParentContentId : contentId ]
        }
    }
}

private extension VDependencyManager {
    var refreshControlColor: UIColor? {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
}
