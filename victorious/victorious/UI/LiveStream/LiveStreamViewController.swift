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
    
    /// If this interval is too small, the scrolling animations will become choppy
    /// as they step on each other before finishing.
    private let kFetchMessagesInterval: NSTimeInterval = 2.0
    
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
    
    private var timerManager: VTimerManager?
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
        
        let conversationID = dataSource.conversation.remoteId!.integerValue
        LiveStreamOperationUpdate(conversationID: conversationID).queue() { (results, error) in
            self.dataSource.loadMessages(pageType: .First)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //beginLiveUpdates()
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
        
        scrollPaginator.disabled = true
        collectionView.v_applyChangeInSection(0, from:oldValue, to:newValue, animated: true) {
            dispatch_after(1.0) {
                self.scrollPaginator.disabled = false
            }
        }
        
        return
        
        let willScroll = collectionView.contentSize.height > collectionView.bounds.height
        guard willScroll else {
            collectionView.v_applyChangeInSection(0, from:oldValue, to:newValue, animated: true)
            return
        }
        
        if !scrollPaginator.isUserScrolling && !dataSource.shouldStashNewContent && dataSource.currentPageType == nil {
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
       
        } else if let pageType = dataSource.currentPageType {
            switch pageType {
            case .Previous:
                self.reloadForPreviousPageFrom(oldValue, to: newValue)
            default:
                collectionView.v_applyChangeInSection(0, from:oldValue, to:newValue, animated: true)
            }
        }
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: VDataSourceState, to newState: VDataSourceState) {
        collectionView.v_updateState( newState, noContentView: noContentView )
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didReceiveError error: NSError) {}
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didPurgeVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        self.reloadForPreviousPageFrom(oldValue, to: newValue)
    }
    
    func reloadForPreviousPageFrom(oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        
        // Because we're scrolling up in this view controller, we need to do a bit of
        // careful reloading and scroll position adjustment when loading next pages
        let oldContentSize = self.collectionView.contentSize
        let oldOffset = self.collectionView.contentOffset
        
        scrollPaginator.disabled = true
        collectionView.v_applyChangeInSection(0, from:oldValue, to:newValue, animated: false) {
            let newContentSize = self.collectionView.contentSize
            let newOffset = CGPoint(x: 0, y: oldOffset.y + (newContentSize.height - oldContentSize.height) )
            self.collectionView.contentOffset = newOffset
        }
    }
    
    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() {
        if !dataSource.isLoading() {
            dataSource.loadMessages(pageType: .Next)
        }
        //self.dataSource.loadUnstashedPage(.Next)
    }
    
    func shouldLoadPreviousPage() {
        if !dataSource.isLoading() {
            dataSource.loadMessages(pageType: .Previous)
        }
        //self.dataSource.loadUnstashedPage(.Previous)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollPaginator.scrollViewDidScroll(scrollView)
        
        // Regular pagination through `scrollPaginator` should only be active when
        // new items are not being stashed
        /*if dataSource.shouldStashNewContent {
            scrollPaginator.scrollViewDidScroll(scrollView)
        }
        
        if scrollPaginator.isUserScrolling && scrollView.contentOffset.y <= previousScrollPosition.y {
            // When scrolling up to look at older items
            dataSource.shouldStashNewContent = true
        }
        previousScrollPosition = scrollView.contentOffset*/
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollPaginator.scrollViewWillBeginDragging(scrollView)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollPaginator.scrollViewDidEndDecelerating(scrollView)
    }
    
    // MARK: - Live Update
    
    func beginLiveUpdates() {
        guard self.timerManager == nil else {
            return
        }
        let timerManager = VTimerManager.scheduledTimerManagerWithTimeInterval( kFetchMessagesInterval,
            target: self,
            selector: Selector("onUpdate"),
            userInfo: nil,
            repeats: true
        )
        // To keep the timer running while scrolling:
        NSRunLoop.mainRunLoop().addTimer(timerManager.timer, forMode: NSRunLoopCommonModes)
        
        self.timerManager = timerManager
    }
    
    func endLiveUpdates() {
        self.timerManager?.invalidate()
        self.timerManager = nil
    }
    
    func onUpdate() {
        dataSource.refreshRemote()
    }
}
