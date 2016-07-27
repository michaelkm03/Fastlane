//
//  TutorialViewController.swift
//  victorious
//
//  Created by Tian Lan on 4/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, ChatFeed, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TutorialNetworkDataSourceDelegate, VBackgroundContainer {
    
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
    
    private var edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
    
    private var timerManager: VTimerManager?
    
    var onContinue: (() -> Void)?
    
    // MARK: - ChatFeed
    
    weak var nextSender: ForumEventSender? = nil
    var dependencyManager: VDependencyManager!
    var showPendingContents: Bool = false
    
    @IBOutlet private(set) weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = chatInterfaceDataSource
            collectionView.delegate = self
            collectionView.backgroundColor = nil
        }
    }
    
    lazy private(set) var chatInterfaceDataSource: ChatInterfaceDataSource = {
        let mainFeedDependency: VDependencyManager = self.dependencyManager.childDependencyForKey("mainFeed") ?? self.dependencyManager
        let dataSource = TutorialCollectionViewDataSource(dependencyManager: mainFeedDependency)
        dataSource.delegate = self
        dataSource.registerCells(for: self.collectionView)
        
        return dataSource
    }()
    
    func setTopInset(value: CGFloat) {
        // Do nothing for tutorial screen
    }
    
    func setBottomInset(value: CGFloat) {
        // Do nothing for tutorial screen
    }

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
        dependencyManager.configureNavigationItem(navigationController?.navigationBar.topItem)
    }
    
    // MARK: - UICollectionViewFlowLayoutDelegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return chatInterfaceDataSource.desiredCellSize(for: collectionView, at: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return edgeInsets
    }
    
    // MARK: - TutorialNetworkDataSourceDelegate
    
    func didReceiveNewMessage(message: ChatFeedContent) {
        handleNewItems([message], loadingType: .newer)
    }

    func didFinishFetchingAllItems() {
        continueButton.hidden = false
        UIView.animateWithDuration(1.0) { [weak self] in
            self?.continueButton.alpha = 1.0
        }
    }
    
    var chatFeedItemWidth: CGFloat {
        return collectionView.bounds.width
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return view
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
