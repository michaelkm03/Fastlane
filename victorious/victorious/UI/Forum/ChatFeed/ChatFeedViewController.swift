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
    
    private var edgeInsets = UIEdgeInsets(top: 100.0, left: 0.0, bottom: 20.0, right: 0.0)
    private var bottomMargin: CGFloat = 10.0
    private let gradientBlendLength: CGFloat = 80.0
    
    var dependencyManager: VDependencyManager!
    
    private lazy var dataSource: ChatFeedDataSource = {
        return ChatFeedDataSource(dependencyManager: self.dependencyManager)
    }()
    
    private lazy var gradientMask: UIView = {
        let frame = self.collectionContainerView.bounds
        let gradientView = VLinearGradientView(frame: frame)
        gradientView.setColors([ UIColor.clearColor(), UIColor.blackColor() ])
        gradientView.locations = [
            (self.edgeInsets.top - self.gradientBlendLength)/frame.height,
            (self.edgeInsets.top)/frame.height
        ]
        gradientView.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientView.endPoint = CGPoint(x: 0.5, y: 1.0)
        return gradientView
    }()
    
    private let scrollPaginator = VScrollPaginator()
    private var previousScrollPosition = CGPoint.zero
    
    private var selectedMessageUserID: Int?
    
    @IBOutlet private var moreContentController: NewItemsController!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionContainerView: UIView!
    @IBOutlet private weak var collectionConainerCenterVertical: NSLayoutConstraint!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientMask.frame = collectionContainerView.bounds
    }
    
    // MARK: - NewItemsControllerDelegate
    
    func onMoreContentSelected() {
        
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionContainerView.maskView = gradientMask
        
        edgesForExtendedLayout = .Bottom
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
        dataSource.delegate = self
        dataSource.registerCellsWithCollectionView( collectionView )
        
        collectionView.dataSource = self.dataSource
        collectionView.delegate = self
        
        scrollPaginator.activeOnlyWhenUserIsScrolling = true
        scrollPaginator.delegate = self
        
        moreContentController.depedencyManager = dependencyManager.newItemsDependency
        moreContentController.delegate = self
        moreContentController.hide(animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        selectedMessageUserID = nil
        dataSource.beginLiveUpdates()
        dataSource.refreshRemote()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        dataSource.endLiveUpdates()
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
        
        if !scrollPaginator.isUserScrolling {
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
        guard let media = messageCell.viewData.media,
            let preloadedImage = messageCell.preloadedImage else {
                return
        }
        delegate?.chatFeed(self, didSelectMedia:media, withPreloadedImage: preloadedImage, fromView: messageCell)
    }
    
    //MARK: - ChatFeed
    
    func setTopInset(value: CGFloat) {
        
    }
    
    func setBottomInset(value: CGFloat) {
        collectionConainerCenterVertical.constant = -value
        view.layoutIfNeeded()
    }
}

private extension VDependencyManager {
    
    var newItemsDependency: VDependencyManager {
        return childDependencyForKey("newItems")!
    }
}
