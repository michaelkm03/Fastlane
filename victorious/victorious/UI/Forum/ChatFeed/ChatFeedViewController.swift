//
//  ChatFeedViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ChatFeedViewController: UIViewController, ChatFeed, UICollectionViewDelegateFlowLayout, VPaginatedDataSourceDelegate, VScrollPaginatorDelegate, NewItemsControllerDelegate, MessageCellDelegate {
    
    weak var delegate: ChatFeedDelegate? //< ChatFeed protocol
    
    let transitionDelegate = VTransitionDelegate(transition: VSimpleModalTransition())
    
    private struct Layout {
        private static let bottomMargin: CGFloat = 20.0
        private static let topMargin: CGFloat = 70.0
    }
    
    private var edgeInsets = UIEdgeInsets(top: Layout.topMargin, left: 0.0, bottom: Layout.bottomMargin, right: 0.0)
    
    var dependencyManager: VDependencyManager!
    
    private lazy var dataSource: ChatFeedDataSource = {
        return ChatFeedDataSource(dependencyManager: self.dependencyManager)
    }()
    
    private let scrollPaginator = VScrollPaginator()
    private var previousScrollPosition = CGPoint.zero
    
    @IBOutlet private var moreContentController: NewItemsController!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewBottom: NSLayoutConstraint!
    
    //MARK: - ChatFeed
    
    func setTopInset(value: CGFloat) {
        print("top = \(value)")
        edgeInsets.top = value + Layout.topMargin + collectionViewBottom.constant
    }
    
    func setBottomInset(value: CGFloat) {
        collectionViewBottom.constant = value
        collectionView.superview?.layoutIfNeeded()
    }
    
    // MARK: - ForumEventReceiver
        
    var childEventReceivers: [ForumEventReceiver] {
        return [ dataSource ]
    }
        
    // MARK: - NewItemsControllerDelegate
        
    func onNewItemsSelected() {
        
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = .Bottom
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
        dataSource.delegate = self
        dataSource.registerCellsWithCollectionView( collectionView )
        
        collectionView.dataSource = self.dataSource
        collectionView.delegate = self
        
        scrollPaginator.delegate = self
        
        moreContentController.depedencyManager = dependencyManager.newItemsDependency
        moreContentController.delegate = self
        moreContentController.hide(animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.startDequeueingMessages()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        dataSource.stopDequeueingMessages()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let messageCell = cell as! MessageCell
        messageCell.delegate = self
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return dataSource.collectionView( collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return edgeInsets
    }
    
    var shouldAutoScroll: Bool {
        let height = collectionView.contentSize.height - (edgeInsets.top + edgeInsets.bottom) - collectionView.bounds.height
        let yValue = max(height, 0)
        let bottomOffset = CGPoint(x: 0, y: yValue)
        return collectionView.contentOffset.y >= bottomOffset.y
    }
    
    // MARK: - VPaginatedDataSourceDelegate
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didUpdateStashedItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        if newValue.count > 0 {
            moreContentController.count = newValue.count
            moreContentController.show()
            
        } else if newValue.count == 0 && oldValue.count > 0 {
            moreContentController.hide()
            collectionView.v_scrollToBottomAnimated(true)
        }
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        
        let willScroll = collectionView.contentSize.height > collectionView.bounds.height
        guard willScroll else {
            collectionView.v_applyChangeInSection(0, from:oldValue, to:newValue, animated: true)
            return
        }
        
        if shouldAutoScroll {
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
        
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didReceiveError error: NSError) {}
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didPurgeVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        reloadForPreviousPageFrom(oldValue, to: newValue)
    }
    
    func reloadForPreviousPageFrom(oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        
        // Because we're scrolling up in this view controller, we need to do a bit of
        // careful reloading and scroll position adjustment when loading next pages
        let oldContentSize = self.collectionView.contentSize
        let oldOffset = self.collectionView.contentOffset
        
        collectionView.v_applyChangeInSection(0, from:oldValue, to:newValue, animated: false) {
            let newContentSize = self.collectionView.contentSize
            let newOffset = CGPoint(x: 0, y: oldOffset.y + (newContentSize.height - oldContentSize.height) )
            self.collectionView.contentOffset = newOffset
        }
    }
    
    // MARK: - MessageCellDelegate
    
    func messageCellDidSelectAvatarImage(messageCell: MessageCell) {
        guard let indexPath = collectionView.indexPathForCell(messageCell) else {
            return
        }
        let message = dataSource.visibleItems[ indexPath.row ] as! ChatMessage
        guard let userID = message.sender.remoteId?.integerValue else {
            return
        }
        delegate?.chatFeed(self, didSelectUserWithUserID: userID)
    }
    
    func messageCellDidSelectMedia(messageCell: MessageCell) {
        guard let media = messageCell.viewData.media else {
            return
        }
        delegate?.chatFeed(self, didSelectMedia:media)
    }
    
    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() {
    
    }
    
    func shouldLoadPreviousPage() {
    
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollPaginator.scrollViewDidScroll(scrollView)
    }
}

private extension VDependencyManager {
    
    var newItemsDependency: VDependencyManager {
        return self
//        return childDependencyForKey("newItems")!
    }
}
