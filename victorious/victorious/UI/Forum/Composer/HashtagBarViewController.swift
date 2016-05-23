//
//  HashtagBarViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// Displays and manages a collection view populated with hashtags.
class HashtagBarViewController: UIViewController {
    
    static func new(dependencyManager: VDependencyManager, containerHeightConstraint: NSLayoutConstraint) -> HashtagBarViewController {
        
        let hashtagBar = v_initialViewControllerFromStoryboard() as HashtagBarViewController
        hashtagBar.dependencyManager = dependencyManager
        hashtagBar.barContainerHeightConstraint = containerHeightConstraint
        return hashtagBar
    }
    
    @IBOutlet weak private var collectionView: UICollectionView!
    
    private(set) var dependencyManager: VDependencyManager!
    
    private(set) var hashtagBarController: HashtagBarController!
    
    weak private var barContainerHeightConstraint: NSLayoutConstraint?
    
    @IBOutlet weak private var collectionViewHeightConstraint: NSLayoutConstraint!
    
    /// The current text that should be used to search for hashtags.
    /// Can cause constraint values to change.
    var searchText: String? {
        didSet {
            hashtagBarController.searchText = searchText
            if searchText != nil {
                barContainerHeightConstraint?.constant = hashtagBarController.preferredHeight
            } else {
                barContainerHeightConstraint?.constant = 0
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hashtagBarController = HashtagBarController(dependencyManager: dependencyManager, collectionView: collectionView)
        collectionViewHeightConstraint.constant = hashtagBarController.preferredCollectionViewHeight
    }
}
