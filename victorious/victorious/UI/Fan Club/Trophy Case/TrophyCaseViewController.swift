//
//  TrophyCaseViewController.swift
//  victorious
//
//  Created by Tian Lan on 2/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import UIKit

class TrophyCaseViewController: UIViewController, UICollectionViewDelegate, VBackgroundContainer {
    
    var dependencyManager: VDependencyManager!
    private(set) var trophyCaseDataSource: TrophyCaseCollectionViewDataSource?
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = trophyCaseDataSource
            collectionView.delegate = self
        }
    }
    
    // MARK: - Factory Functions
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> TrophyCaseViewController {
        let trophyCaseViewController = TrophyCaseViewController.v_fromStoryboard() as TrophyCaseViewController
        trophyCaseViewController.dependencyManager = dependencyManager
        trophyCaseViewController.trophyCaseDataSource = TrophyCaseCollectionViewDataSource(dependencyManager: dependencyManager)
        
        return trophyCaseViewController
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIComponents()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dependencyManager.trackViewWillAppear(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        dependencyManager.trackViewWillDisappear(self)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        
        guard
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as? TrophyCaseAchievementCollectionViewCell,
            let achievement = cell.achievement
        else {
                return
        }
        
        let detailViewController = InterstitialAlertViewController.newWithDependencyManager(dependencyManager)
        let alert = Alert(title: achievement.title, description: achievement.detailedDescription)
        detailViewController.alert = alert
        InterstitialManager.sharedInstance.receive(alert)
    }
    
    // MARK: - Background Container
    
    func backgroundContainerView() -> UIView {
        return self.view
    }
    
    // MARK: - Private Functions
    
    private func configureUIComponents() {
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.title = dependencyManager.stringForKey(VDependencyManagerTitleKey)
        dependencyManager.addBackgroundToBackgroundHost(self)
    }
}
