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
        
        static let interItemSpace: CGFloat = 1
        static let sectionEdgeInsets: UIEdgeInsets = UIEdgeInsetsMake(6, 0, 6, 0)
        static let recentSectionEdgeInsets: UIEdgeInsets = {
            var insets = sectionEdgeInsets
            insets.left = 1
            insets.right = 1
            return insets
        }()
        static let minimumContentAspectRatio: CGFloat = 0.5
        static let maximumContentAspectRatio: CGFloat = 2
        static let minimizedContentAspectRatio: CGFloat = 9 / 16
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
        collectionView.registerClass(VShelfContentCollectionViewCell.self, forCellWithReuseIdentifier: VShelfContentCollectionViewCell.suggestedReuseIdentifier())

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
                else {
                    if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(VShelfContentCollectionViewCell.suggestedReuseIdentifier(), forIndexPath: indexPath) as? VShelfContentCollectionViewCell {
                        cell.streamItem = exploreStream?.streamItems[indexPath.row] as? VStreamItem
                        cell.dependencyManager = dependencyManager
                        return cell
                    }
                }
            }
        }
        return failureCellFactory.noContentCellForCollectionView(collectionView, atIndexPath: indexPath)
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

extension VExploreViewController: CHTCollectionViewDelegateWaterfallLayout {
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let stream = exploreStream {
            if let shelves = stream.shelves.array as? [Shelf] {
                if indexPath.section != recentContentSection() {
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
                    var width = collectionView.bounds.width - ( Constants.interItemSpace * 2 + Constants.recentSectionEdgeInsets.left + Constants.recentSectionEdgeInsets.right )
                    width /= 2
                    width = floor(width)
                    return CGSize(width: width, height: heightAt(indexPath, forCollectionViewWidth: width))
                }
            }
        }
        return failureCellFactory.cellSizeForCollectionViewBounds(collectionView.bounds)
    }
    
    private func heightAt(indexPath: NSIndexPath, forCollectionViewWidth width: CGFloat) -> CGFloat {
        if let exploreStream = exploreStream {
            let filter = VObjectManager.sharedManager().filterForStream(currentStream)
            /// Warning: for testing
            let perPageNumber = filter.perPageNumber.integerValue
            let pageLocation = indexPath.row % perPageNumber
            if pageLocation == 0 {
                return width * Constants.minimizedContentAspectRatio
            }
            else if pageLocation == 1 {
                return width
            }
            else if let layout = collectionView.collectionViewLayout as? CHTCollectionViewWaterfallLayout where pageLocation >= perPageNumber - 2 {
                //Need to consider the height of the bottom 2 cells to make sure they level out properly
                if let columnsAsNumbers = layout.heightsForColumnsInSection(UInt(recentContentSection())) as? [NSNumber] {
                    let columnHeights = columnsAsNumbers.map({CGFloat($0.floatValue)})
                    let shortColumnHeight = minElement(columnHeights)
                    let tallColumnHeight = maxElement(columnHeights)
                    
                    if pageLocation == perPageNumber - 2 {
                        //Make sure 2nd to last cell leaves enough space for the last cell to show properly
                        var contentHeight = heightFor(exploreStream.streamItems[indexPath.row] as? VStreamItem, inCollectionViewWithWidth: width)
                        let potentialColumnHeight = shortColumnHeight + contentHeight + Constants.interItemSpace
                        let minimumLastCellHeight = Constants.minimumContentAspectRatio * width + Constants.interItemSpace
                        
                        if abs(potentialColumnHeight - tallColumnHeight) < minimumLastCellHeight {
                            //We don't enough space for the last cell to be shown with the minimum height, adjust this cell to make that possible.
                            if shortColumnHeight + minimumLastCellHeight * 2 < tallColumnHeight {
                                //Can fit both into the currently short column, just do that.
                                return tallColumnHeight - shortColumnHeight - minimumLastCellHeight
                            }
                            else {
                                //The added height of this cell's content, even at maximum shortness, will make us unable to add more to this column.
                                //Extend the height of this cell's content to allow the last cell to get added to the other column.
                                return tallColumnHeight + minimumLastCellHeight - shortColumnHeight - Constants.interItemSpace
                            }
                        }
                        else {
                            return contentHeight
                        }
                    }
                    else if pageLocation == perPageNumber - 1 {
                        return tallColumnHeight - shortColumnHeight - Constants.interItemSpace
                    }
                }
            }
            
            return heightFor(exploreStream.streamItems[indexPath.row] as? VStreamItem, inCollectionViewWithWidth: width)
        }
        return 0
    }
    
    private func heightFor(streamItem: VStreamItem?, inCollectionViewWithWidth width: CGFloat) -> CGFloat {
        if let sequence = streamItem as? VSequence {
            let aspectRatio = min( 1 / sequence.previewAssetAspectRatio(), Constants.maximumContentAspectRatio )
            return width * aspectRatio
        }
        else {
            //Default to 1:1 for unexpected content types
            return width
        }
    }
    
    private func recentContentSection() -> Int {
        if let exploreStream = exploreStream {
            return exploreStream.shelves.count
        }
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.interItemSpace
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.interItemSpace
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnCountForSection section: Int) -> Int {
        return section == recentContentSection() ? 2 : 1
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.interItemSpace
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return section == recentContentSection() ? Constants.recentSectionEdgeInsets : Constants.sectionEdgeInsets
    }
}

extension VExploreViewController : VHashtagSelectionResponder {
    
    func hashtagSelected(text: String!) {
        if let hashtag = text, stream = dependencyManager?.hashtagStreamWithHashtag(hashtag) {
            self.navigationController?.pushViewController(stream, animated: true)
        }
    }
}
