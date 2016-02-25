//
//  LiveStreamViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class LiveStreamViewController: UIViewController, UICollectionViewDelegateFlowLayout, VPaginatedDataSourceDelegate, VScrollPaginatorDelegate, VMultipleContainerChild, MoreContentControllerDelegate {
    
    private let kSectionBottomMargin: CGFloat = 50.0
    
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
    private var isScrolling: Bool = false
    
    @IBOutlet private var moreContentController: MoreContentController!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - VMultipleContainerChild
    
    func multipleContainerDidSetSelected(isDefault: Bool) { }
    
    var multipleContainerChildDelegate: VMultipleContainerChildDelegate?
    
    // MARK: - MoreContentControllerDelegate
    
    func onMoreContentSelected() {
        if !isScrolling {
            collectionView.v_scrollToBottomAnimated(true)
        }
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = .Bottom
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = UIColor.blackColor()
        
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
    
    // MARK: - VPaginatedDataSourceDelegate
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        
        guard collectionView.contentSize.height > collectionView.bounds.height else {
            collectionView.v_applyChangeInSection(0, from:oldValue, to:newValue, animated: true)
            return
        }
        
        if shouldScrollToBottom {
            // Some tricky stuff to make sure the collection view's content size is updated enough
            // so that the scroll to bottom actually works
            CATransaction.begin()
            CATransaction.setCompletionBlock() {
                dispatch_after(0.0) {
                    if !self.isScrolling {
                        self.collectionView.v_scrollToBottomAnimated(true)
                    }
                }
            }
            collectionView.v_applyChangeInSection(0, from:oldValue, to:newValue, animated: true)
            CATransaction.commit()
        } else {
            let newContentCount = newValue.array.filter { !oldValue.containsObject( $0 ) }.count
            moreContentController.incrementMessageCountBy( newContentCount )
            moreContentController.show()
            collectionView.v_applyChangeInSection(0, from:oldValue, to:newValue, animated: false)
        }
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: VDataSourceState, to newState: VDataSourceState) {
        collectionView.v_updateState( newState, noContentView: noContentView )
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didReceiveError error: NSError) {
        
    }
    
    private var shouldScrollToBottom: Bool {
        let indexPath = NSIndexPath(forItem: dataSource.visibleItems.count-1, inSection: 0)
        let collectionViewLayout = collectionView.collectionViewLayout
        let size = dataSource.collectionView( collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
        let contentOffsetAtBottom = collectionView.contentSize.height - collectionView.bounds.height - (size.height + kSectionBottomMargin * 2.0)
        return collectionView.contentOffset.y >= contentOffsetAtBottom
    }
    
    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() { }
    
    func shouldLoadPreviousPage() {
        dataSource.loadMessages( pageType: .Next )
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentOffsetAtBottom = collectionView.contentSize.height - collectionView.bounds.height - 100.0
        if collectionView.contentOffset.y >= contentOffsetAtBottom {
            moreContentController.hide()
        }
        
        //scrollPaginator.scrollViewDidScroll(scrollView)
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
        dataSource.refreshRemote()
    }
}

struct PaginedDataSourceChange {
    let oldVisibleItems: NSOrderedSet
    let itemsAdded: [AnyObject]
    let itemsRemoved: [AnyObject]
    let itemsPurged: [AnyObject]
}
