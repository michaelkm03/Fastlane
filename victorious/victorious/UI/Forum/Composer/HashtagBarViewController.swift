//
//  HashtagBarViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

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
    
    weak private var barContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var searchText: String? {
        didSet {
            hashtagBarController.searchText = searchText
            if searchText != nil {
                barContainerHeightConstraint.constant = hashtagBarController.preferredHeight
                collectionViewHeightConstraint.constant = hashtagBarController.preferredCollectionViewHeight
            } else {
                barContainerHeightConstraint.constant = 0
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hashtagBarController = HashtagBarController(dependencyManager: dependencyManager, collectionView: collectionView)
    }
}
