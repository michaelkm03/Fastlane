//
//  HashtagBarViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

protocol HashtagBarViewControllerAnimationDelegate: class {
    
    func hashtagBarViewController(hashtagBarViewController: HashtagBarViewController, isUpdatingConstraints updateBlock: Void -> ())
}

/// Displays and manages a collection view populated with hashtags.
class HashtagBarViewController: UIViewController, HashtagBarControllerSearchDelegate {
    
    static func new(dependencyManager: VDependencyManager, containerHeightConstraint: NSLayoutConstraint) -> HashtagBarViewController {
        
        let hashtagBar = v_initialViewControllerFromStoryboard() as HashtagBarViewController
        hashtagBar.dependencyManager = dependencyManager
        hashtagBar.barContainerHeightConstraint = containerHeightConstraint
        return hashtagBar
    }
    
    @IBOutlet weak private var collectionView: UICollectionView!
    
    private(set) var dependencyManager: VDependencyManager!
    
    private(set) lazy var hashtagBarController: HashtagBarController = {
        let hashtagBarController = HashtagBarController(dependencyManager: self.dependencyManager, collectionView: self.collectionView)
        hashtagBarController.searchDelegate = self
        return hashtagBarController
    }()
    
    private var barContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private var collectionViewHeightConstraint: NSLayoutConstraint!
    
    weak var animationDelegate: HashtagBarViewControllerAnimationDelegate?
    
    func hashtagBarController(hashtagBarController: HashtagBarController, populatedWithHashtags hashtags: [String]) {
        let barHeight = hashtags.isEmpty ? 0 : hashtagBarController.preferredHeight
        if barContainerHeightConstraint.constant != barHeight {
            if let delegate = animationDelegate {
                delegate.hashtagBarViewController(self, isUpdatingConstraints: { [weak self] in
                    self?.barContainerHeightConstraint.constant = barHeight
                })
            } else {
                barContainerHeightConstraint.constant = barHeight
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewHeightConstraint.constant = hashtagBarController.preferredCollectionViewHeight
    }
}
