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
class VExploreViewController: VAbstractStreamCollectionViewController, UICollectionViewDelegate, UISearchBarDelegate {
    
    struct Constants {
        static let trendingTopicShelfKey = "trendingShelf"
    }
    
    @IBOutlet weak private var searchBar: UISearchBar!
    private var trendingTopicShelfFactory: TrendingTopicShelfFactory?
    private var streamShelfFactory: VStreamContentCellFactory?
    private let failureCellFactory: VNoContentCollectionViewCellFactory = VNoContentCollectionViewCellFactory(acceptableContentClasses: [Shelf.self])

    /// The dependencyManager that is used to manage dependencies of explore screen
    private(set) var dependencyManager: VDependencyManager?
    
    /// MARK: - View Controller Initialization
    
    class func new( #dependencyManager: VDependencyManager ) -> VExploreViewController {
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        if let exploreVC = storyboard.instantiateInitialViewController() as? VExploreViewController {
            exploreVC.dependencyManager = dependencyManager
            // WARNING: Testing code, remember to remove!
            exploreVC.currentStream = VStream(forPath: "/api/sequence/explore/1/15", inContext: dependencyManager.objectManager().managedObjectStore.mainQueueManagedObjectContext, withEntityName: ExploreStream.entityName())
            // For trending topic shelf
            exploreVC.trendingTopicShelfFactory = dependencyManager.templateValueOfType(TrendingTopicShelfFactory.self, forKey: Constants.trendingTopicShelfKey) as? TrendingTopicShelfFactory
            exploreVC.streamShelfFactory = VStreamContentCellFactory(dependencyManager: dependencyManager)
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
        
        trendingTopicShelfFactory?.registerCellsWithCollectionView(collectionView)
        streamShelfFactory?.registerCellsWithCollectionView(collectionView)
        failureCellFactory.registerNoContentCellWithCollectionView(collectionView)

        self.streamDataSource = VStreamCollectionViewDataSource(stream: currentStream)
        self.streamDataSource.delegate = self;
        self.streamDataSource.collectionView = self.collectionView;
        self.collectionView.dataSource = self.streamDataSource;
        self.collectionView.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.refresh(refreshControl)
    }
    
    private var exploreStream: ExploreStream? {
        if currentStream != nil {
            if let currentStream = currentStream as? ExploreStream {
                return currentStream
            }
            fatalError("The explore view controller is being shown with a non-explore-stream stream")
        }
        return nil
    }
    
    /// Mark: - UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if let searchVC = VUsersAndTagsSearchViewController .newWithDependencyManager(dependencyManager) {
            v_navigationController().innerNavigationController.pushViewController(searchVC, animated: true)
        }
    }
}

extension VExploreViewController : VStreamCollectionDataDelegate {
    
    override func dataSource(dataSource: VStreamCollectionViewDataSource!, cellForIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        if let stream = exploreStream {
            if let shelves = stream.shelves.array as? [Shelf] {
                if indexPath.section < shelves.count {
                    // Trending topic shelf
                    
                    let shelf = shelves[indexPath.section]
                    if shelf.itemSubType == VStreamItemSubTypeTrendingTopic {
                        if let cell = trendingTopicShelfFactory?.collectionView(collectionView, cellForStreamItem: shelf, atIndexPath: indexPath) as? TrendingTopicShelfCollectionViewCell {
                            return cell
                        }
                    }
                    else {
                        if let cell = streamShelfFactory?.collectionView(collectionView, cellForStreamItem: shelf, atIndexPath: indexPath) {
                            return cell
                        }
                    }
                }
                
                /// Warning: recent goes here
            }
        }
        let cell = failureCellFactory.noContentCellForCollectionView(collectionView, atIndexPath: indexPath)
        cell.backgroundColor = UIColor.redColor()
        return cell
    }
    
    override func numberOfSectionsForDataSource(dataSource: VStreamCollectionViewDataSource!) -> Int {
        if let stream = exploreStream {
            // Total number of shelves plus one section for recent content
            return stream.shelves.count + 1
        }
        return 0
    }
    
    override func dataSource(dataSource: VStreamCollectionViewDataSource!, numberOfRowsInSection section: UInt) -> Int {
        if let stream = exploreStream {
            if section < UInt(stream.shelves.count) {
                return 1
            }
            else {
                return stream.streamItems.count
            }
        }
        return 0
    }
}

extension VExploreViewController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if let stream = exploreStream {
            if let shelves = stream.shelves.array as? [Shelf] {
                if indexPath.section < shelves.count {
                    let shelf = shelves[indexPath.section]
                    
                    // Trending topic shelf
                    if shelf.itemSubType == VStreamItemSubTypeTrendingTopic {
                        if let trendingFactory = trendingTopicShelfFactory {
                            return trendingFactory.sizeWithCollectionViewBounds(collectionView.bounds, ofCellForStreamItem: shelf)
                        }
                    }
                    else {
                        if let streamShelfFactory = streamShelfFactory {
                            return streamShelfFactory.sizeWithCollectionViewBounds(collectionView.bounds, ofCellForStreamItem: shelf)
                        }
                    }
                }
                else {
                    // WARNING: Placeholder for recent content
                    return CGSize(width: 100, height: 100)
                }
            }
        }
        return failureCellFactory.cellSizeForCollectionViewBounds(collectionView.bounds)
    }
}

extension VExploreViewController : VHashtagSelectionResponder {
    
    func hashtagSelected(text: String!) {
        if let hashtag = text, stream = dependencyManager?.hashtagStreamWithHashtag(hashtag) {
            self.navigationController?.pushViewController(stream, animated: true)
        }
    }
}
