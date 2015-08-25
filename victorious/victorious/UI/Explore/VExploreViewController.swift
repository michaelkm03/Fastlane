//
//  VExploreViewController.swift
//  victorious
//
//  Created by Tian Lan on 8/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// Base view controller for the explore screen that gets
/// presented when "explore" button on the tab bar is tapped
class VExploreViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var collectionView: UICollectionView!
    
    var shelf: Shelf? {
        didSet {
            self.collectionView.reloadData()
        }
    }

    /// The dependencyManager that is used to manage dependencies of explore screen
    private(set) var dependencyManager: VDependencyManager?
    private let numberOfSectionsInCollectionView = 3
    
    /// MARK: - View Controller Initialization
    
    class func new( #dependencyManager: VDependencyManager ) -> VExploreViewController {
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        if let exploreVC = storyboard.instantiateInitialViewController() as? VExploreViewController {
            exploreVC.dependencyManager = dependencyManager
            return exploreVC
        }
        fatalError("Failed to instantiate VExploreViewController with storyboard")
    }
    
    /// MARK: - View Controller LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.v_supplementaryHeaderView = searchBar
        self.automaticallyAdjustsScrollViewInsets = false;
        self.extendedLayoutIncludesOpaqueBars = true;
        
        // WARNING: Testing
        self.collectionView.registerClass(TrendingTopicShelfCollectionViewCell.self, forCellWithReuseIdentifier: TrendingTopicShelfCollectionViewCell.suggestedReuseIdentifier())
        
        VObjectManager.sharedManager().getExplore({ (op, obj, results) -> Void in
            if let stream = results.last as? VStream {
                for (ind, streamItem) in enumerate(stream.streamItems) {
                    if let newShelf = streamItem as? Shelf {
                        if newShelf.itemSubType == VStreamItemSubTypeTrendingTopic {
                            self.shelf = newShelf
                        }
                    }
                }
            }

        }, failBlock: { (op, err) -> Void in
            println(err)
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /// MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        switch (section) {
        case 0:
            numberOfRows = 3
        case 1:
            numberOfRows = self.shelf != nil ? 1 : 0
        case 2:
            numberOfRows = 12
        default:
            fatalError("Unexpected number of sections in collection view")
        }
        
        return numberOfRows
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let shelf = self.shelf {
            if indexPath.section == 1 {
                if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TrendingTopicShelfCollectionViewCell.suggestedReuseIdentifier(), forIndexPath: indexPath) as? TrendingTopicShelfCollectionViewCell {
                    cell.dependencyManager = self.dependencyManager
                    cell.shelf = self.shelf
                    return cell
                }
            }
        }
        if let placeHolderCell = collectionView.dequeueReusableCellWithReuseIdentifier("placeHolder", forIndexPath: indexPath) as? UICollectionViewCell {
            return placeHolderCell
        }
        fatalError("Could not find a cell for item!")
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return numberOfSectionsInCollectionView
    }
    
    /// Mark: - UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if let searchVC = VUsersAndTagsSearchViewController .newWithDependencyManager(dependencyManager) {
            v_navigationController().innerNavigationController.pushViewController(searchVC, animated: true)
        }
    }
}

extension VExploreViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.section == 1 {
            return CGSize(width: self.view.bounds.width, height: 160)
        }
        return CGSize(width: 100, height: 100)
    }
}
