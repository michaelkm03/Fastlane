//
//  TrophyCaseViewController.swift
//  victorious
//
//  Created by Tian Lan on 2/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import UIKit

class TrophyCaseViewController: UIViewController, UICollectionViewDelegate {
    
    var dependencyManager: VDependencyManager?
    private(set) var trophyCaseDataSource: TrophyCaseCollectionViewDataSource?
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = trophyCaseDataSource
            collectionView.delegate = self
        }
    }
    
    //MARK: - Factory method
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> TrophyCaseViewController {
        let trophyCaseViewController = TrophyCaseViewController.v_fromStoryboard() as TrophyCaseViewController
        trophyCaseViewController.dependencyManager = dependencyManager
        trophyCaseViewController.trophyCaseDataSource = TrophyCaseCollectionViewDataSource(dependencyManager: dependencyManager)
        
        return trophyCaseViewController
    }
    
    //MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUIComponents()
    }
    
    func configureUIComponents() {
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
        if let dependencyManager = dependencyManager {
            navigationItem.title = dependencyManager.stringForKey("title")
        }
    }
    
    //MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? TrophyCaseAchievementCollectionViewCell,
            let achievement = cell.achievement,
            let dependencyManager = dependencyManager else {
                return
        }
        
        let detailViewController = AchievementDetailViewController.makeAchievementDetailViewControllerWithDependencyManager(dependencyManager, achievement: achievement)
        presentViewController(detailViewController, animated: false, completion: nil)
    }
}
