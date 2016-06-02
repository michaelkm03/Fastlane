//
//  ChatFeedViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ChatFeedViewController: UIViewController, ChatFeed, ChatFeedDataSourceDelegate, UICollectionViewDelegateFlowLayout, VScrollPaginatorDelegate, NewItemsControllerDelegate, ChatFeedMessageCellDelegate {
    private lazy var dataSource: ChatFeedDataSourceType = {
        return ChatFeedDataSource(dependencyManager: self.dependencyManager)
    }()
    
    private struct Layout {
        private static let bottomMargin: CGFloat = 20.0
        private static let topMargin: CGFloat = 20.0
    }
    
    private var edgeInsets = UIEdgeInsets(top: Layout.topMargin, left: 0.0, bottom: Layout.bottomMargin, right: 0.0)
    
    var dependencyManager: VDependencyManager!
    
    private lazy var focusHelper: VCollectionViewStreamFocusHelper = {
        return VCollectionViewStreamFocusHelper(collectionView: self.collectionView)
    }()
    
    private let scrollPaginator = VScrollPaginator()
    
    // Used to create a temporary window where immediate re-stashing is disabled after unstashing
    private var canStashNewItems: Bool = true
    
    @IBOutlet private var newItemsController: NewItemsController!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var collectionViewBottom: NSLayoutConstraint!
    
    //MARK: - ChatFeed
    
    weak var delegate: ChatFeedDelegate?
    
    func setTopInset(value: CGFloat) {
        edgeInsets.top = value + Layout.topMargin
    }
    
    func setBottomInset(value: CGFloat) {
        collectionViewBottom.constant = value
        collectionView.superview?.layoutIfNeeded()
    }
    
    // MARK: - ForumEventReceiver
        
    var childEventReceivers: [ForumEventReceiver] {
        return [dataSource]
    }
    
    // MARK: - ForumEventSender
    
    weak var nextSender: ForumEventSender?
    
    // MARK: - NewItemsControllerDelegate
        
    func onNewItemsSelected() {
//        paginatedDataSource.unstashAll()
        canStashNewItems = false
        dispatch_after(1.0) {
            self.canStashNewItems = true
        }
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = .None
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
        dataSource.delegate = self
        dataSource.registerCells(for: collectionView)
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        scrollPaginator.delegate = self
        
        dataSource.nextSender = self
        
        newItemsController.depedencyManager = dependencyManager
        newItemsController.delegate = self
        newItemsController.hide(animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.startCheckingForNewItems()
        focusHelper.updateFocus()
        startTimestampUpdate()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        paginatedDataSource.startStashingNewItems()
        focusHelper.endFocusOnAllCells()
        stopTimestampUpdate()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let messageCell = cell as! ChatFeedMessageCell
        messageCell.delegate = self
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return dataSource.collectionView(collectionView, sizeForItemAtIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return edgeInsets
    }
    
    // MARK: - ChatFeedDataSourceDelegate
    
    func chatFeedDataSource(dataSource: ChatFeedDataSourceType, didLoadItems newItems: [ContentModel], loadingType: PaginatedLoadingType) {
        guard newItems.count > 0 else {
            return
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let collectionView = self.collectionView
        let bottomOffset = collectionView.contentSize.height - collectionView.contentOffset.y
        let wasScrolledToBottom = collectionView.v_isScrolledToBottom
        
        collectionView.performBatchUpdates({
            switch loadingType {
            case .newer:
                let previousCount = dataSource.items.count - newItems.count
                
                collectionView.insertItemsAtIndexPaths((0 ..< newItems.count).map {
                    NSIndexPath(forItem: previousCount + $0, inSection: 0)
                })
            
            case .older:
                collectionView.insertItemsAtIndexPaths((0 ..< newItems.count).map {
                    NSIndexPath(forItem: $0, inSection: 0)
                })
                
            case .refresh:
                collectionView.reloadData()
            }
        }, completion: { _ in
            // If we loaded older items, maintain the previous scroll position.
            if loadingType == .older {
                collectionView.contentOffset = CGPoint(x: 0.0, y: collectionView.contentSize.height - bottomOffset)
            }
            
            CATransaction.commit()
            
            // If we loaded newer items and we were scrolled to the bottom, scroll down to reveal the new content.
            if loadingType == .newer && wasScrolledToBottom {
                collectionView.setContentOffset(collectionView.v_bottomOffset, animated: true)
            }
        })
    }
    
    // MARK: - VPaginatedDataSourceDelegate
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didUpdateStashedItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        // TODO: Replace this.
        
//        let newItemsContainsUserMessage = newValue
//            .filter { !oldValue.containsObject($0) }
//            .flatMap { $0 as? ChatFeedMessage }
//            .contains { $0.content.authorModel.id == VCurrentUser.user()?.remoteId.integerValue }
//        
//        let allItemsWereUnstashed = newValue.count == 0 && oldValue.count > 0
// 
//        if newItemsContainsUserMessage || allItemsWereUnstashed {
//            // Unstash and scroll to bottom
//            newItemsController.hide()
//            collectionView.v_scrollToBottomAnimated(true)
//            
//        }  else if newValue.count > 0 {
//            // Update the count of stashed items
//            newItemsController.count = paginatedDataSource.stashedItemsCount
//            newItemsController.show()
//            return
//        }
    }
    
//    var totalHeight: CGFloat {
//        var totalHeight: CGFloat = 0.0
//        for i in 0..<collectionView.numberOfItemsInSection(0) {
//            let indexPath = NSIndexPath(forItem: i, inSection: 0)
//            totalHeight += collectionDataSource.collectionView(collectionView, sizeForItemAtIndexPath: indexPath).height
//        }
//        return totalHeight
//    }
    
    // TODO: Replace paginated data source stuff.
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        // TODO: Fix autoscrolling and bottom-alignment of content.
        
//        let shouldAutoScrollLocal = shouldAutoScroll
//        let hasEnoughContentToScroll = totalHeight >= collectionView.bounds.height
////        collectionView.scrollEnabled = hasEnoughContentToScroll
//        if hasEnoughContentToScroll {
//            setTopInset(0.0)
//            CATransaction.begin()
//            CATransaction.setCompletionBlock() {
//                dispatch_after(0.0) {
//                    if shouldAutoScrollLocal {
//                        self.collectionView.v_scrollToBottomAnimated(true)
//                    }
//                }
//            }
//            // Don't animate the change, the auto scroll will bring it into view
//            collectionView.v_applyChangeInSection(0, from: oldValue, to: newValue, animated: false)
//            CATransaction.commit()
//        } else {
//            collectionView.v_applyChangeInSection(0, from: oldValue, to: newValue, animated: false)
//            CATransaction.begin()
//            let targetInset = max(self.collectionView.bounds.height - Layout.topMargin, 0.0)
//            self.setTopInset(targetInset)
//            self.collectionView.collectionViewLayout.invalidateLayout()
//            CATransaction.setCompletionBlock() {
//                dispatch_after(0.0) {
//                    self.collectionView.v_scrollToBottomAnimated(true)
//                }
//            }
//            CATransaction.commit()
//        }
    }
    
    // TODO: Fix purging.
    
//    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didPurgeVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
//        
//        let oldContentSize = self.collectionView.contentSize
//        let oldOffset = self.collectionView.contentOffset
//        
//        collectionView.v_applyChangeInSection(0, from: oldValue, to: newValue, animated: false) {
//            let newContentSize = self.collectionView.contentSize
//            let newOffset = CGPoint(x: 0, y: oldOffset.y + (newContentSize.height - oldContentSize.height) )
//            self.collectionView.contentOffset = newOffset
//        }
//    }
    
    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadPreviousPage() {
        send(.loadOldContent)
    }
    
    // MARK: - ChatFeedMessageCellDelegate
    
    func messageCellDidSelectAvatarImage(messageCell: ChatFeedMessageCell) {
        guard let userID = messageCell.content?.authorModel.id else {
            return
        }
        
        delegate?.chatFeed(self, didSelectUserWithUserID: userID)
    }
    
    func messageCellDidSelectMedia(messageCell: ChatFeedMessageCell) {
        guard let asset = messageCell.content?.assetModels.first else {
            return
        }
        
        delegate?.chatFeed(self, didSelectAsset: asset)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollPaginator.scrollViewDidScroll(scrollView)
        
        // TODO: Fix stashing.
        
//        if shouldStash {
//            paginatedDataSource.startStashingNewItems()
//        } else if shouldUnstash {
//            paginatedDataSource.unstashAll()
//            canStashNewItems = false
//            let stashDisabledDuration: NSTimeInterval = 1.0
//            dispatch_after(stashDisabledDuration) {
//                self.canStashNewItems = true
//            }
//        }
        
        focusHelper.updateFocus()
    }
    
//    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
//        isDecelerating = true
//    }
//    
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        isDecelerating = false
//    }
    
    // MARK: - Private
    
    // TODO: Fix stashing.
    
//    private var shouldStash: Bool {
//        return !paginatedDataSource.isStashingNewItems && canStashNewItems && (touchDownController.isTouchDown || isDecelerating)
//    }
//    
//    private var shouldUnstash: Bool {
//        return paginatedDataSource.isStashingNewItems && isScrolledToBottom(withMargin: collectionView.bounds.height * 0.1)
//    }
//    
//    private var isDecelerating: Bool = false
//    
//    private var shouldAutoScroll: Bool {
//        // The user is scrolling or just released is a scroll
//        if touchDownController.isTouchDown || isDecelerating {
//            return false
//        } else {
//            let margin = collectionView.bounds.height
//            return isScrolledToBottom(withMargin: margin) || !canStashNewItems
//        }
//    }
//    
//    private func isScrolledToBottom(withMargin margin: CGFloat) -> Bool {
//        let height = collectionView.contentSize.height - (collectionView.contentInset.top + collectionView.contentInset.bottom) - collectionView.bounds.height
//        let yValue = max(height, 0)
//        let bottomOffset = CGPoint(x: 0, y: yValue)
//        return collectionView.contentOffset.y + margin >= bottomOffset.y
//    }
    
    // MARK: - Timestamp update timer
    
    static let timestampUpdateInterval: NSTimeInterval = 1.0
    
    private var timerManager: VTimerManager?
    
    private func stopTimestampUpdate() {
        timerManager?.invalidate()
        timerManager = nil
    }
    
    private func startTimestampUpdate() {
        guard timerManager == nil else {
            return
        }
        
        timerManager = VTimerManager.addTimerManagerWithTimeInterval(
            ChatFeedViewController.timestampUpdateInterval,
            target: self,
            selector: #selector(onTimerTick),
            userInfo: nil,
            repeats: true,
            toRunLoop: NSRunLoop.mainRunLoop(),
            withRunMode: NSRunLoopCommonModes
        )
        
        onTimerTick()
    }
    
    private dynamic func onTimerTick() {
        dataSource.updateTimestamps(for: collectionView)
    }
}
