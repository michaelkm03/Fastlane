//
//  UserActionsViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 3/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

protocol UserActionsViewControllerDelegate: class {
    func userActionsViewController(viewController: UserActionsViewController, didSelectAction action: UserAction)
}

class UserActionsViewController: UIViewController, UICollectionViewDelegateFlowLayout, VSimpleModalTransitionPresentedViewController {
    
    class func newWithUser(user: VUser, dependencyManager: VDependencyManager) -> UserActionsViewController {
        let viewController: UserActionsViewController = UserActionsViewController.v_fromStoryboard("Chat", identifier: "UserActionsViewController")
        viewController.user = user
        viewController.dependencyManager = dependencyManager
        return viewController
    }
    
    lazy private var dataSource: UserActionsDataSource = {
        return UserActionsDataSource(user: self.user)
    }()
    
    weak var delegate: UserActionsViewControllerDelegate?
    
    private var dependencyManager: VDependencyManager!
    private var user: VUser!
    
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak private var backgroundButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.registerCellsWithCollectionView(collectionView)
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        modalContainer = collectionView
        backgroundScreen = backgroundButton
        
        collectionView.performBatchUpdates(
            {
                self.collectionView.reloadData()
            }, completion: { finished in
                self.collectionViewHeight.constant = self.collectionView.contentSize.height
            }
        )
    }
    
    @IBAction private func onBackgroundTapped(sender: UIButton?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return dataSource.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let action = dataSource.actionForIndexPath(indexPath) else {
            assertionFailure()
            return
        }
        
        delegate?.userActionsViewController(self, didSelectAction: action)
    }
    
    // MARK: - VSimpleModalTransitionPresentedViewController
    
    weak var modalContainer: UIView?
    
    weak var backgroundScreen: UIView?
}
