//
//  LiveStreamViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class LiveStreamViewController: UIViewController, UICollectionViewDelegateFlowLayout, VPaginatedDataSourceDelegate, VScrollPaginatorDelegate, VMultipleContainerChild {
    
    private var dependencyManager = VDependencyManager(parentManager: nil, configuration: nil, dictionaryOfClassesByTemplateName: nil)
    
    static func newWithDependencyManager(dependencyManager: VDependencyManager) -> LiveStreamViewController {
        let viewController = LiveStreamViewController()
        viewController.dependencyManager = dependencyManager
        return viewController
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self.dataSource
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(collectionView)
        self.view.v_addFitToParentConstraintsToSubview(collectionView)
        return collectionView
    }()
    
    private lazy var noContentView: VNoContentView = {
        let noContentView: VNoContentView = VNoContentView.v_fromNib() 
        noContentView.icon = UIImage(named: "user-icon")?.imageWithRenderingMode(.AlwaysTemplate)
        noContentView.title = NSLocalizedString("We ain't got nothing.", comment:"")
        noContentView.message = NSLocalizedString("So leave me alone.", comment:"")
        noContentView.resetInitialAnimationState()
        return noContentView
    }()
    
    private var timer: VTimerManager?
    private let scrollPaginator = VScrollPaginator()
    private var hasLoadedOnce = false
    private let dataSource = LiveStreamDataSource()
    
    // MARK: - VMultipleContainerChild
    
    func multipleContainerDidSetSelected(isDefault: Bool) {
        
    }
    
    var multipleContainerChildDelegate: VMultipleContainerChildDelegate?
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Live Stream"
        
        dataSource.delegate = self
        dataSource.registerCells( collectionView )
        dataSource.loadPage(.First) { error in
            self.scrollPaginator.delegate = self
        }
        
        view.backgroundColor = UIColor.blackColor()
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
    
    // MARK: - VPaginatedDataSourceDelegate
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        
        let shouldAnimate = hasLoadedOnce
        
        // Some tricky stuff to make sure the table view's content size is updated enough
        // so that the scroll to bottom actually works
        CATransaction.begin()
        CATransaction.setCompletionBlock() {
            dispatch_after(0.0) {
                self.collectionView.v_scrollToBottomAnimated(shouldAnimate)
            }
        }
        collectionView.v_applyChangeInSection(0, from:oldValue, to:newValue, animated: shouldAnimate)
        CATransaction.commit()
        
        hasLoadedOnce = true
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: VDataSourceState, to newState: VDataSourceState) {
        collectionView.v_updateState( newState, noContentView: noContentView )
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didReceiveError error: NSError) {
        v_showErrorDefaultError()
    }
    
    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() { }
    
    func shouldLoadPreviousPage() {
        dataSource.loadPage( .Next )
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollPaginator.scrollViewDidScroll(scrollView)
    }
    
    // MARK: - Live Update
    
    func beginLiveUpdates() {
        self.timer = VTimerManager.scheduledTimerManagerWithTimeInterval( 2.0,
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
        dataSource.refreshRemote() { (results, error) in
            if !results.isEmpty {
                self.collectionView.v_scrollToBottomAnimated(true)
            }
        }
    }
}
