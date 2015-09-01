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
    
    struct Constants {
        static let trendingTopicShelfKey = "trendingShelf"
    }
    
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var collectionView: UICollectionView!
    private var trendingTopicShelfFactory: TrendingTopicShelfFactory?
    
    // Array of shelves to be displayed before recent content
    var shelves: [Shelf] = []

    /// The dependencyManager that is used to manage dependencies of explore screen
    private(set) var dependencyManager: VDependencyManager?
    
    /// MARK: - View Controller Initialization
    
    class func new( #dependencyManager: VDependencyManager ) -> VExploreViewController {
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        if let exploreVC = storyboard.instantiateInitialViewController() as? VExploreViewController {
            exploreVC.dependencyManager = dependencyManager
            // For trending topic shelf
            exploreVC.trendingTopicShelfFactory = dependencyManager.templateValueOfType(TrendingTopicShelfFactory.self, forKey: Constants.trendingTopicShelfKey) as? TrendingTopicShelfFactory
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
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        VObjectManager.sharedManager().getExplore({ (op, obj, results) -> Void in
            if let stream = results.last as? VStream {
                for (index, streamItem) in enumerate(stream.streamItems) {
                    if let newShelf = streamItem as? Shelf {
                        self.trendingTopicShelfFactory?.registerCellsWithCollectionView(self.collectionView)
                        self.shelves.append(newShelf)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionView.reloadData()
                    self.trackVisibleCells()
                })
            }

        }, failBlock: { (op, err) -> Void in
            // TODO: Deal with error
            println("error")
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /// MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.section < shelves.count {
            // Trending topic shelf
            
            let shelf = shelves[indexPath.section]
            if shelf.itemSubType == VStreamItemSubTypeTrendingTopic {
                if let cell = trendingTopicShelfFactory?.collectionView(collectionView, cellForStreamItem: shelf, atIndexPath: indexPath) as? TrendingTopicShelfCollectionViewCell {
                    return cell
                }
            }
        }
        
        if let placeHolderCell = collectionView.dequeueReusableCellWithReuseIdentifier("placeHolder", forIndexPath: indexPath) as? UICollectionViewCell {
            placeHolderCell.contentView.backgroundColor = UIColor.blackColor()
            return placeHolderCell
        }
        fatalError("Could not find a cell for item!")
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section < shelves.count {
            return 1
        }
        
        // WARNING: Placeholder for recent content
        return 69
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // Total number of shelves plus one section for recent content
        return shelves.count + 1
    }
    
    /// Mark: - UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if let searchVC = VUsersAndTagsSearchViewController .newWithDependencyManager(dependencyManager) {
            v_navigationController().innerNavigationController.pushViewController(searchVC, animated: true)
        }
    }
    
    /// MARK: Tracking
    
    func trackVisibleCells() {
        // WARNING: needs to be implemented for explore marquee and recent cells
        
        dispatch_after(0.1) {
            for cell in self.collectionView.visibleCells() {
                if let cell = cell as? TrendingTopicShelfCollectionViewCell {
                    cell.streamItemVisibilityTrackingHelper.trackVisibleSequences()
                }
            }
        }
    }
}

extension VExploreViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.section < shelves.count {
            let shelf = shelves[indexPath.section]
            // Trending topic shelf
            if shelf.itemSubType == VStreamItemSubTypeTrendingTopic {
                if let trendingFactory = trendingTopicShelfFactory {
                    return trendingFactory.sizeWithCollectionViewBounds(collectionView.bounds, ofCellForStreamItem: shelf)
                }
            }
            else {
                // WARNING: Placeholder for other shelves
                return CGSize(width: self.collectionView.bounds.width, height: 150)
            }
        }
        // WARNING: Placeholder for recent content
        return CGSize(width: 100, height: 100)
    }
}

extension VExploreViewController : VHashtagSelectionResponder {
    
    func hashtagSelected(text: String!) {
        if let hashtag = text, stream = dependencyManager?.hashtagStreamWithHashtag(hashtag) {
            self.navigationController?.pushViewController(stream, animated: true)
        }
    }
}
