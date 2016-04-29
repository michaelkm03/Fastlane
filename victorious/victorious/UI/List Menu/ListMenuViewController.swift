//
//  ListMenuViewController.swift
//  victorious
//
//  Created by Tian Lan on 4/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// View Controller for the entire List Menu Component, which is currently being displayed as the left navigation pane
/// of a sliding scaffold.
class ListMenuViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, VCoachmarkDisplayer, VNavigationDestination, VBackgroundContainer {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = collectionViewDataSource
            collectionView.delegate = self
        }
    }
    
    var dependencyManager: VDependencyManager!
    
    private lazy var collectionViewDataSource: ListMenuCollectionViewDataSource = {
        ListMenuCollectionViewDataSource(dependencyManager: self.dependencyManager, listMenuViewController: self)
    }()
    
    // MARK: - Initialization
    
    static func newWithDependencyManager(dependencyManager: VDependencyManager) -> ListMenuViewController {
        let viewController = self.v_initialViewControllerFromStoryboard() as ListMenuViewController
        viewController.dependencyManager = dependencyManager
        dependencyManager.addBackgroundToBackgroundHost(viewController)
        
        return viewController
    }
    
    // MARK: - UIViewController overrides
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    // MARK: - UICollectionView Delegate Flow Layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let listMenuSection = ListMenuSection(rawValue: indexPath.section)!
        
        switch listMenuSection {
        case .creator:
            return CGSize(width: view.bounds.width, height: ListMenuCreatorCollectionViewCell.preferredHeight)
        case .community:
            return CGSize(width: view.bounds.width, height: ListMenuCommunityCollectionViewCell.preferredHeight)
        case .hashtags:
            return CGSize(width: view.bounds.width, height: ListMenuHashtagCollectionViewCell.preferredHeight)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 0, bottom: 24, right: 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.bounds.width, height: ListMenuSectionHeaderView.preferredHeight)
    }
    
    // MARK: - UICollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let listMenuSection = ListMenuSection(rawValue: indexPath.section)!
        
        switch listMenuSection {
        case .creator:
            break
        case .community:
            break
        case .hashtags:
            break
        }
    }
    
    // MARK - VCoachmarkDisplayer
    
    func screenIdentifier() -> String! {
        return dependencyManager.stringForKey(VDependencyManagerIDKey)
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return view
    }
}
