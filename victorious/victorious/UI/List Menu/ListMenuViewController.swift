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
class ListMenuViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = collectionViewDataSource
            collectionView.delegate = self
        }
    }
    
    private var dependencyManager: VDependencyManager!
    
    private lazy var collectionViewDataSource: ListMenuCollectionViewDataSource = {
        ListMenuCollectionViewDataSource(dependencyManager: self.dependencyManager, listMenuViewController: self)
    }()
    
    // MARK: - Initialization
    
    static func newWithDependencyManager(dependencyManager: VDependencyManager) -> ListMenuViewController {
        let viewController = self.v_initialViewControllerFromStoryboard() as ListMenuViewController
        viewController.dependencyManager = dependencyManager
        
        return viewController
    }
    
    // MARK: - UICollectionView Delegate Flow Layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let listMenuSection = ListMenuSection(rawValue: indexPath.section)!
        
        switch listMenuSection {
        case .creator:
            return CGSizeZero
        case .community:
            return CGSizeZero
        case .hashtags:
            return CGSizeMake(collectionView.bounds.width, 80)
        }
    }
}
