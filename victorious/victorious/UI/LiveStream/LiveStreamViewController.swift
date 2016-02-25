//
//  LiveStreamViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class LiveStreamViewController: UIViewController, UICollectionViewDelegateFlowLayout, LiveStreamDataSourceDelegate, VScrollPaginatorDelegate, VMultipleContainerChild, MoreContentControllerDelegate {
    
    private let kSectionBottomMargin: CGFloat = 60.0
    
    private var dependencyManager: VDependencyManager!
    
    static func newWithDependencyManager(dependencyManager: VDependencyManager) -> LiveStreamViewController {
        let viewController: LiveStreamViewController = LiveStreamViewController.v_initialViewControllerFromStoryboard("LiveStream")
        viewController.dependencyManager = dependencyManager
        viewController.title = dependencyManager.stringForKey("title")
        return viewController
    }
    
    private lazy var noContentView: VNoContentView = {
        let noContentView: VNoContentView = VNoContentView.v_fromNib()
        noContentView.icon = UIImage(named: "user-icon")?.imageWithRenderingMode(.AlwaysTemplate)
        noContentView.title = NSLocalizedString("We ain't got nothing.", comment:"")
        noContentView.message = NSLocalizedString("So leave me alone.", comment:"")
        noContentView.resetInitialAnimationState()
        return noContentView
    }()
    
    private lazy var dataSource: LiveStreamDataSource = {
        return LiveStreamDataSource(conversation: self.conversation, dependencyManager: self.dependencyManager)
    }()
    
    private lazy var conversation: VConversation = {
        let persistentStore = MainPersistentStore()
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let publicConversation: VConversation = context.v_createObject()
            publicConversation.remoteId = 99999
            publicConversation.postedAt = NSDate()
            return publicConversation
        }
    }()
    
    private var timer: VTimerManager?
    private let scrollPaginator = VScrollPaginator()
    private var previousScrollPosition = CGPoint.zero
    private var isScrolling: Bool = false
    
    @IBOutlet private var moreContentController: MoreContentController!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - VMultipleContainerChild
    
    func multipleContainerDidSetSelected(isDefault: Bool) { }
    
    var multipleContainerChildDelegate: VMultipleContainerChildDelegate?
    
    // MARK: - MoreContentControllerDelegate
    
    func onMoreContentSelected() {
        dataSource.shouldStashNewContent = false
        collectionView.v_scrollToBottomAnimated(true)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = .Bottom
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = UIColor.v_colorFromHexString("170724")
        
        dataSource.delegate = self
        dataSource.registerCellsWithCollectionView( collectionView )
        
        collectionView.dataSource = self.dataSource
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clearColor()
        
        dataSource.loadMessages(pageType: .First) { (results, error) in
            self.scrollPaginator.delegate = self
        }
        
        moreContentController.delegate = self
        moreContentController.hide(animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        beginLiveUpdates()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        endLiveUpdates()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return dataSource.collectionView( collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: kSectionBottomMargin, right: 0)
    }
    
    // MARK: - LiveStreamDataSourceDelegate
    
    func liveStreamDataSourceDidUpdateStashedItems( liveStreamDataSource: LiveStreamDataSource) {
        let count = liveStreamDataSource.stashedItems.count
        if count > 0 {
            moreContentController.count = liveStreamDataSource.stashedItems.count
            moreContentController.show()
        } else {
            moreContentController.hide()
        }
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        
        guard collectionView.contentSize.height > collectionView.bounds.height else {
            collectionView.v_applyChangeInSection(0, from:oldValue, to:newValue, animated: true)
            return
        }
        
        if !dataSource.shouldStashNewContent && !isScrolling {
            // Some tricky stuff to make sure the collection view's content size is updated enough
            // so that the scroll to bottom actually works
            CATransaction.begin()
            CATransaction.setCompletionBlock() {
                dispatch_after(0.0) {
                    if !self.dataSource.shouldStashNewContent {
                        self.collectionView.v_scrollToBottomAnimated(true)
                    }
                }
            }
            collectionView.v_applyChangeInSection(0, from:oldValue, to:newValue, animated: true)
            CATransaction.commit()
            
        }
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: VDataSourceState, to newState: VDataSourceState) {
        collectionView.v_updateState( newState, noContentView: noContentView )
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didReceiveError error: NSError) {
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didPurgeItems items: NSOrderedSet) {
        collectionView.v_reloadForPreviousPage()
    }
    
    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() {
        dataSource.loadMessages( pageType: .Previous )
    }
    
    func shouldLoadPreviousPage() {
        dataSource.loadMessages( pageType: .Next )
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // Regular pagination through `scrollPaginator` should only be active when
        // new items are not being stashed
        if dataSource.shouldStashNewContent {
            scrollPaginator.scrollViewDidScroll(scrollView)
        }
        
        if isScrolling && scrollView.contentOffset.y <= previousScrollPosition.y {
            // When scrolling up to look at older items
            dataSource.shouldStashNewContent = true
        }
        previousScrollPosition = scrollView.contentOffset
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        isScrolling = true
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isScrolling = false
    }
    
    // MARK: - Live Update
    
    func beginLiveUpdates() {
        self.timer = VTimerManager.scheduledTimerManagerWithTimeInterval( 1.0,
            target: self,
            selector: Selector("onUpdate"),
            userInfo: nil,
            repeats: true
        )
    }
    
    func endLiveUpdates() {
        self.timer?.invalidate()
    }
    
    func onUpdate() {
        if !dataSource.shouldStashNewContent {
            dataSource.purgeVisibleItemsWithinLimit(25)
        }
        dataSource.loadMessages(pageType: .First)
    }
}
