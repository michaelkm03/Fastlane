//
//  TutorialViewController.swift
//  victorious
//
//  Created by Tian Lan on 4/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TutorialNetworkDataSourceDelegate, VBackgroundContainer {
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = collectionViewDataSource
            collectionView.delegate = self
            collectionView.backgroundColor = nil
            collectionView.scrollEnabled = false
        }
    }
    
    @IBOutlet private weak var continueButton: UIButton! {
        didSet {
            continueButton.hidden = true
            continueButton.alpha = 0
            continueButton.setTitleColor(dependencyManager.continueButtonTitleColor, forState: .Normal)
            continueButton.setTitle(dependencyManager.continueButtonTitleText, forState: .Normal)
            continueButton.titleLabel?.font = dependencyManager.continueButtonTitleFont
            continueButton.backgroundColor = dependencyManager.continueButtonBackgroundColor
        }
    }
    
    private var dependencyManager: VDependencyManager!
    
    lazy private var collectionViewDataSource: ChatInterfaceDataSource = {
        let mainFeedDependency: VDependencyManager = self.dependencyManager.childDependencyForKey("mainFeed") ?? self.dependencyManager
        let dataSource = TutorialCollectionViewDataSource(dependencyManager: mainFeedDependency)
        dataSource.delegate = self
        dataSource.registerCells(for: self.collectionView)
        
        return dataSource
    }()
    
    private var edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
    
    private var timerManager: VTimerManager?
    
    var onContinue: (() -> Void)?

    // MARK: - Initialization
    
    static func newWithDependencyManager(dependencyManager: VDependencyManager) -> TutorialViewController {
        let viewController: TutorialViewController = TutorialViewController.v_initialViewControllerFromStoryboard()
        viewController.dependencyManager = dependencyManager
        
        return viewController
    }
    
    // MARK: - View Controller Life Cycle
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    @IBAction private func didTapContinueButton(sender: UIButton) {
        // We want the closure to be called after dismissing self, so we capture the closure locally first
        // and then call it in the completion block.
        let onContinue = self.onContinue
        dismissViewControllerAnimated(true) {
            onContinue?()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dependencyManager.addBackgroundToBackgroundHost(self)
        dependencyManager.applyStyleToNavigationBar(navigationController?.navigationBar)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startTimestampUpdate()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimestampUpdate()
    }
    
    // MARK: - UICollectionViewFlowLayoutDelegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionViewDataSource.desiredCellSize(for: collectionView, at: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return edgeInsets
    }
    
    // MARK: - TutorialNetworkDataSourceDelegate
    
    func didReceiveNewMessage(message: ChatFeedContent) {
        handleNewItems([message], loadingType: .newer)
    }

    func didFinishFetchingAllItems() {
        collectionView.scrollEnabled = true
        continueButton.hidden = false
        UIView.animateWithDuration(1.0) { [weak self] in
            self?.continueButton.alpha = 1.0
        }
    }
    
    private func handleNewItems(newItems: [ChatFeedContent], loadingType: PaginatedLoadingType, completion: (() -> Void)? = nil) {
        guard newItems.count > 0 || loadingType == .refresh else {
            return
        }
        
        // Disable UICollectionView insertion animation.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let collectionView = self.collectionView
        let wasScrolledToBottom = collectionView.v_isScrolledToBottom
        
        updateCollectionView(with: newItems, loadingType: loadingType) {
            collectionView.collectionViewLayout.invalidateLayout()
            
            CATransaction.commit()
            
            // If we loaded newer items and we were scrolled to the bottom, or if we refreshed the feed, scroll down to
            // reveal the new content.
            if (loadingType == .newer && wasScrolledToBottom) || loadingType == .refresh {
                collectionView.setContentOffset(collectionView.v_bottomOffset, animated: loadingType != .refresh)
            }
            
            completion?()
        }
    }
    
    private func updateCollectionView(with newItems: [ChatFeedContent], loadingType: PaginatedLoadingType, completion: () -> Void) {
        if loadingType == .refresh {
            collectionView.reloadData()
            completion()
        }
        else {
            let collectionView = self.collectionView
            
            // The collection view's layout information is guaranteed to be updated properly in the completion handler
            // of this method, which allows us to properly manage scrolling. We can't call `reloadData` in this method,
            // though, so we have to do that separately.
            collectionView.performBatchUpdates({
                switch loadingType {
                case .newer:
                    let previousCount = self.collectionViewDataSource.visibleItems.count - newItems.count
                    
                    collectionView.insertItemsAtIndexPaths((0 ..< newItems.count).map {
                        NSIndexPath(forItem: previousCount + $0, inSection: 0)
                        })
                    
                case .older:
                    if let layout = collectionView.collectionViewLayout as? ChatFeedCollectionViewLayout {
                        layout.contentSizeWhenInsertingAbove = collectionView.contentSize
                    }
                    else {
                        assertionFailure("Chat feed's collection view did not have the required layout type ChatFeedCollectionViewLayout.")
                    }
                    
                    collectionView.insertItemsAtIndexPaths((0 ..< newItems.count).map {
                        NSIndexPath(forItem: $0, inSection: 0)
                        })
                    
                case .refresh:
                    break
                }
                }, completion: { _ in
                    completion()
            })
        }
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return view
    }
    
    // MARK: - Timestamp update timer
    
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
    
    func onTimerTick() {
        collectionViewDataSource.updateTimestamps(in: collectionView)
    }
}

private extension VDependencyManager {
    private var continueButtonChildDependency: VDependencyManager? {
        return childDependencyForKey("continueButton")
    }
    
    var continueButtonTitleColor: UIColor? {
        return continueButtonChildDependency?.colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var continueButtonTitleFont: UIFont? {
        return continueButtonChildDependency?.fontForKey(VDependencyManagerButton1FontKey)
    }
    
    var continueButtonTitleText: String? {
        return continueButtonChildDependency?.stringForKey("text")
    }
    
    var continueButtonBackgroundColor: UIColor? {
        return continueButtonChildDependency?.colorForKey(VDependencyManagerLinkColorKey)
    }
}
