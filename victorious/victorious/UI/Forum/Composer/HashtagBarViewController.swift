//
//  HashtagBarViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class HashtagBarViewController: UIViewController {
    
    private var hashtagBarController: HashtagBarController?
    
    var dependencyManager: VDependencyManager? {
        didSet {
            updateHashtagBarController()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            updateHashtagBarController()
        }
    }
    
    weak private var barContainerHeightConstraint: NSLayoutConstraint?
    
    var searchText: String? {
        didSet {
            hashtagBarController?.searchText = searchText
            if searchText == nil {
                barContainerHeightConstraint?.constant = 0
            }
        }
    }
    
    private func updateHashtagBarController() {
        
        if let dependencyManager = dependencyManager where isViewLoaded() {
            hashtagBarController = HashtagBarController(dependencyManager: dependencyManager, collectionView: collectionView)
        }
    }
}
