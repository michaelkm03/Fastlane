//
//  LiveStreamViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class LiveStreamViewController: UIViewController, UICollectionViewDelegateFlowLayout, VPaginatedDataSourceDelegate, VScrollPaginatorDelegate, VMultipleContainerChild, MoreContentControllerDelegate {
    
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
        
        scrollPaginator.delegate = self
        
        moreContentController.delegate = self
        moreContentController.hide(animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        beginLiveUpdates()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        endLiveUpdates()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return dataSource.collectionView( collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: kSectionBottomMargin, right: 0)
    }
    
    // MARK: - VPaginatedDataSourceDelegate
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didUpdateStashedItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        if newValue.count > 0 {
            moreContentController.count = newValue.count
            moreContentController.show()
        } else {
            moreContentController.hide()
        }
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        
        let willScroll = collectionView.contentSize.height > collectionView.bounds.height
        guard willScroll else {
            collectionView.v_applyChangeInSection(0, from:oldValue, to:newValue, animated: true)
            return
        }
        
        if !scrollPaginator.isUserScrolling && !dataSource.shouldStashNewContent {
            // Some tricky stuff to make sure the collection view's content size is updated enough
            // so that the scroll to bottom actually works
            CATransaction.begin()
            CATransaction.setCompletionBlock() {
                dispatch_after(0.0) {
                    self.collectionView.v_scrollToBottomAnimated(true)
                }
            }
            collectionView.v_applyChangeInSection(0, from:oldValue, to:newValue, animated: true)
            CATransaction.commit()
       
        } else {
            collectionView.v_applyChangeInSection(0, from:oldValue, to:newValue, animated: true)
        }
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: VDataSourceState, to newState: VDataSourceState) {
        collectionView.v_updateState( newState, noContentView: noContentView )
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didReceiveError error: NSError) {}
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didPurgeVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        collectionView.v_reloadForPreviousPage()
    }
    
    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() {
        self.dataSource.loadUnstashedPage(.Next)
    }
    
    func shouldLoadPreviousPage() {
        self.dataSource.loadUnstashedPage(.Previous)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // Regular pagination through `scrollPaginator` should only be active when
        // new items are not being stashed
        if dataSource.shouldStashNewContent {
            scrollPaginator.scrollViewDidScroll(scrollView)
        }
        
        if scrollPaginator.isUserScrolling && scrollView.contentOffset.y <= previousScrollPosition.y {
            // When scrolling up to look at older items
            dataSource.shouldStashNewContent = true
        }
        previousScrollPosition = scrollView.contentOffset
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollPaginator.scrollViewWillBeginDragging(scrollView)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollPaginator.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    // MARK: - Live Update
    
    func beginLiveUpdates() {
        guard self.timer == nil else {
            return
        }
        self.timer = VTimerManager.scheduledTimerManagerWithTimeInterval( 1.0,
            target: self,
            selector: Selector("onUpdate"),
            userInfo: nil,
            repeats: true
        )
    }
    
    func endLiveUpdates() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func onUpdate() {
        dataSource.refreshRemote()
    }
}
