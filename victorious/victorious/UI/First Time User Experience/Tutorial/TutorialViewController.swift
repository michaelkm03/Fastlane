//
//  TutorialViewController.swift
//  victorious
//
//  Created by Tian Lan on 4/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

class TutorialViewController: UIViewController, ChatFeed, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TutorialNetworkDataSourceDelegate, VBackgroundContainer {
    
    @IBOutlet var continueButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var continueButton: UIButton! {
        didSet {
            continueButton.setTitleColor(dependencyManager.continueButtonTitleColor, for: .normal)
            continueButton.setTitle(dependencyManager.continueButtonTitleText, for: .normal)
            continueButton.titleLabel?.font = dependencyManager.continueButtonTitleFont
            continueButton.backgroundColor = dependencyManager.continueButtonBackgroundColor
        }
    }
    
    fileprivate var edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
    
    fileprivate var timerManager: VTimerManager?
    
    var onContinue: (() -> Void)?
    
    // MARK: - ChatFeed
    
    weak var nextSender: ForumEventSender? = nil
    var dependencyManager: VDependencyManager!
    var activeChatRoomID: ChatRoom.ID?
    
    @IBOutlet fileprivate(set) weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = chatInterfaceDataSource
            collectionView.delegate = self
            collectionView.backgroundColor = nil
        }
    }
    
    lazy fileprivate(set) var chatInterfaceDataSource: ChatInterfaceDataSource = {
        let mainFeedDependency: VDependencyManager = self.dependencyManager.childDependency(forKey: "mainFeed") ?? self.dependencyManager
        let dataSource = TutorialCollectionViewDataSource(dependencyManager: mainFeedDependency)
        dataSource.delegate = self
        dataSource.registerCells(for: self.collectionView)
        
        return dataSource
    }()
    
    // MARK: - Managing insets
    
    // Added insets are not used for the tutorial screen.
    var addedTopInset = CGFloat(0.0)
    var addedBottomInset = CGFloat(0.0)

    // MARK: - Initialization
    
    static func new(withDependencyManager dependencyManager: VDependencyManager) -> TutorialViewController {
        let viewController: TutorialViewController = TutorialViewController.v_initialViewControllerFromStoryboard()
        viewController.dependencyManager = dependencyManager
        
        return viewController
    }
    
    // MARK: - View Controller Life Cycle
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction fileprivate func didTapContinueButton(_ sender: UIButton) {
        // We want the closure to be called after dismissing self, so we capture the closure locally first
        // and then call it in the completion block.
        let onContinue = self.onContinue
        dismiss(animated: true) {
            onContinue?()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dependencyManager.addBackground(toBackgroundHost: self)
        dependencyManager.applyStyle(to: navigationController?.navigationBar)
        dependencyManager.configureNavigationItem(navigationController?.navigationBar.topItem)
        
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    // MARK: - UICollectionViewFlowLayoutDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let messageCell = cell as! ChatFeedMessageCell
        messageCell.startDisplaying()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! ChatFeedMessageCell).stopDisplaying()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return chatInterfaceDataSource.desiredCellSize(for: collectionView, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return edgeInsets
    }
    
    // MARK: - TutorialNetworkDataSourceDelegate
    
    func didReceiveNewMessage(_ message: ChatFeedContent) {
        handleNewItems([message], loadingType: .newer)
    }

    func didFinishFetchingAllItems() {
        continueButtonBottomConstraint.constant = 0.0
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }) 
    }
    
    var chatFeedItemWidth: CGFloat {
        return collectionView.bounds.width
    }
    
    // MARK: - ForumEventReceiver
    
    let childEventReceivers = [ForumEventReceiver]()
    
    func receive(_ event: ForumEvent) {}
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return view
    }
}

private extension VDependencyManager {
    var continueButtonChildDependency: VDependencyManager? {
        return childDependency(forKey: "continueButton")
    }
    
    var continueButtonTitleColor: UIColor? {
        return continueButtonChildDependency?.color(forKey: VDependencyManagerMainTextColorKey)
    }
    
    var continueButtonTitleFont: UIFont? {
        return continueButtonChildDependency?.font(forKey: VDependencyManagerButton1FontKey)
    }
    
    var continueButtonTitleText: String? {
        return continueButtonChildDependency?.string(forKey: "text")
    }
    
    var continueButtonBackgroundColor: UIColor? {
        return continueButtonChildDependency?.color(forKey: VDependencyManagerLinkColorKey)
    }
}
