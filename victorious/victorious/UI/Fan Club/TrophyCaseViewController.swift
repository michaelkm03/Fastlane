//
//  TrophyCaseViewController.swift
//  victorious
//
//  Created by Tian Lan on 2/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import UIKit

class TrophyCaseViewController: UIViewController {
    
    var dependencyManager: VDependencyManager?
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            if let dependencyManager = dependencyManager {
                collectionView.dataSource = TrophyCaseCollectionViewDataSource(dependencyManager: dependencyManager)
            }
        }
    }
    
    //MARK: - Factory method
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> TrophyCaseViewController {
        let trophyCaseViewController = TrophyCaseViewController.v_fromStoryboard() as TrophyCaseViewController
        trophyCaseViewController.dependencyManager = dependencyManager
        
        return trophyCaseViewController
    }
    
    //MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
    }
}
