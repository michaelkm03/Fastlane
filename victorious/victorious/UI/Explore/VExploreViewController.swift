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
class VExploreViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {
    
    private struct Constants {
        static let sequenceIDKey = "sequenceID"
        static let marqueeDestinationDirectory = "destionationDirectory"
        static let trendingTopicShelfKey = "trendingShelf"
        static let destinationStreamKey = "destinationStream"
    }
    
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var collectionView: UICollectionView!
    private var trendingTopicShelfFactory: TrendingTopicShelfFactory?
    private var marqueeShelfFactory: VMarqueeCellFactory?
    
    // Array of shelves to be displayed before recent content
    var shelves: [Shelf] = []
    
    /// The dependencyManager that is used to manage dependencies of explore screen
    private(set) var dependencyManager: VDependencyManager?
    
    /// MARK: - View Controller Initialization
    
    class func new( #dependencyManager: VDependencyManager ) -> VExploreViewController {
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        if let exploreVC = storyboard.instantiateInitialViewController() as? VExploreViewController {
            exploreVC.dependencyManager = dependencyManager
            // Factory for marquee shelf
            exploreVC.marqueeShelfFactory = VMarqueeCellFactory(dependencyManager: dependencyManager)
            // Factory for trending topic shelf
            exploreVC.trendingTopicShelfFactory = dependencyManager.templateValueOfType(TrendingTopicShelfFactory.self, forKey: Constants.trendingTopicShelfKey) as? TrendingTopicShelfFactory
            return exploreVC
        }
        fatalError("Failed to instantiate an explore view controller!")
    }
    
    /// MARK: - View Controller LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.v_supplementaryHeaderView = searchBar
        
        automaticallyAdjustsScrollViewInsets = false
        extendedLayoutIncludesOpaqueBars = true
        
        marqueeShelfFactory?.registerCellsWithCollectionView(self.collectionView)
        marqueeShelfFactory?.marqueeController?.setSelectionDelegate(self)
        
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        VObjectManager.sharedManager().getExplore({ (op, obj, results) -> Void in
            if let stream = results.last as? VStream {
                for (index, streamItem) in enumerate(stream.streamItems) {
                    if let newShelf = streamItem as? Shelf {
                        self.trendingTopicShelfFactory?.registerCellsWithCollectionView(self.collectionView)
                        self.shelves.append(newShelf)
                    }
                }
                self.collectionView.reloadData()
            }
            }, failBlock: { (op, err) -> Void in
                // TODO: Deal with error
        })
    }
    
    /// MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.section < shelves.count {
            let shelf = shelves[indexPath.section]
            
            if let subType = shelf.itemSubType {
                switch subType {
                case VStreamItemSubTypeMarquee:
                    if let marqueeCell = marqueeShelfFactory?.collectionView(collectionView, cellForStreamItem: shelf, atIndexPath: indexPath) as? ExploreMarqueeCollectionViewCell {
                        return marqueeCell
                    }
                case VStreamItemSubTypeTrendingTopic:
                    if let trendingTopicsCell = trendingTopicShelfFactory?.collectionView(collectionView, cellForStreamItem: shelf, atIndexPath: indexPath) as? TrendingTopicShelfCollectionViewCell {
                        return trendingTopicsCell
                    }
                default:
                    if let placeHolderCell = collectionView.dequeueReusableCellWithReuseIdentifier("placeHolder", forIndexPath: indexPath) as? UICollectionViewCell {
                        placeHolderCell.contentView.backgroundColor = UIColor.blackColor()
                        return placeHolderCell
                    }
                }
            }
        }
        
        return collectionView.dequeueReusableCellWithReuseIdentifier("placeHolder", forIndexPath: indexPath) as! UICollectionViewCell
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
    
    /// MARK: - UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if let searchVC = VUsersAndTagsSearchViewController.newWithDependencyManager(dependencyManager) {
            v_navigationController().innerNavigationController.pushViewController(searchVC, animated: true)
        }
    }
}

extension VExploreViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.section < shelves.count {
            let shelf = shelves[indexPath.section]
            
            if let subType = shelf.itemSubType {
                switch subType {
                case VStreamItemSubTypeMarquee:
                    if let marqueeFactory = marqueeShelfFactory {
                        return marqueeFactory.sizeWithCollectionViewBounds(collectionView.bounds, ofCellForStreamItem: shelf)
                    }
                case VStreamItemSubTypeTrendingTopic:
                    if let trendingFactory = trendingTopicShelfFactory {
                        return trendingFactory.sizeWithCollectionViewBounds(collectionView.bounds, ofCellForStreamItem: shelf)
                    }
                default:
                    // Do not show a shelf if we don't recognize its type
                    return CGSizeZero
                }
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

extension VExploreViewController : VMarqueeSelectionDelegate {
    func marquee(marquee: VAbstractMarqueeController!, selectedItem streamItem: VStreamItem!, atIndexPath path: NSIndexPath!, previewImage image: UIImage) {
        if let cell = marquee.collectionView.cellForItemAtIndexPath(path) {
            navigate(toStreamItem: streamItem, fromStream: marquee.shelf, withPreviewImage: image, inCell: cell)
        }
        else {
            fatalError("Unable to retrive a collection view cell")
        }
    }
    
    private func navigate(toStream stream: VStream, atStreamItem streamItem: VStreamItem?) {
        let isShelf = stream.isShelf
        var streamCollection: VStreamCollectionViewController?
        
        // The config dictionary here is initialized to solve objc/swift dictionary type inconsistency
        let baseDict = [Constants.sequenceIDKey : stream.remoteId]
        var configDict = NSMutableDictionary(dictionary: baseDict)
        if let name = stream.name {
            configDict[VDependencyManagerTitleKey] = name
        }
        
        // Navigating to a shelf
        if isShelf {
            // WARNING: This shelf portion may need rework when merging in recent post
            configDict[VStreamCollectionViewControllerStreamURLKey] = stream.apiPath
            if let childDependencyManager = self.dependencyManager?.childDependencyManagerWithAddedConfiguration(configDict as [NSObject : AnyObject]) {
                // Hashtag Shelf
                if let tagShelf = stream as? HashtagShelf {
                    streamCollection = childDependencyManager.hashtagStreamWithHashtag(tagShelf.hashtagTitle)
                }
                    // Other shelves
                else {
                    streamCollection = VStreamCollectionViewController.newWithDependencyManager(childDependencyManager)
                }
            }
        }
        // Navigating to a single stream
        else if stream.isSingleStream {
            streamCollection = dependencyManager?.templateValueOfType(VStreamCollectionViewController.self, forKey: Constants.destinationStreamKey, withAddedDependencies: configDict as [NSObject : AnyObject]) as? VStreamCollectionViewController
        }
        
        // show the stream view controller if it has been instantiated
        if let streamViewController = streamCollection {
            streamViewController.currentStream = stream
            streamViewController.targetStreamItem = streamItem
            navigationController?.pushViewController(streamViewController, animated: true)
        }
        // else Show the stream of streams
        else if stream.isStreamOfStreams {
            if let directory = dependencyManager?.templateValueOfType(
                VDirectoryCollectionViewController.self,
                forKey: Constants.marqueeDestinationDirectory ) as? VDirectoryCollectionViewController {
                    directory.currentStream = stream
                    directory.title = stream.name
                    directory.targetStreamItem = streamItem
                    
                    navigationController?.pushViewController(directory, animated: true)
            }
            else {
                // No directory to show, alert the user
                UIAlertView(
                    title: nil,
                    message: NSLocalizedString("GenericFailMessage", comment: ""),
                    delegate: nil,
                    cancelButtonTitle: NSLocalizedString("OK", comment: "")
                )
            }
        }
    }
    
    private func navigate(toStreamItem streamItem: VStreamItem, fromStream stream: VStream, withPreviewImage image: UIImage, inCell cell: UICollectionViewCell) {
        /// Marquee item selection tracking
        let params = [ VTrackingKeyName : streamItem.name ?? "",
            VTrackingKeyRemoteId : streamItem.remoteId ?? ""]
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectItemFromMarquee, parameters: params)
        
        // Navigating to a sequence
        if streamItem is VSequence {
            let event = StreamCellContext(streamItem: streamItem, stream: stream, fromShelf: true)
            
            let extraTrackingInfo: [String : AnyObject]
            if let autoplayCell = cell as? AutoplayTracking {
                extraTrackingInfo = autoplayCell.additionalInfo()
            }
            else {
                extraTrackingInfo = [String : AnyObject]()
            }
            
            showContentView(forCellEvent: event, trackingInfo: extraTrackingInfo, previewImage: image)
        }
        // Navigating to a stream
        else if let stream = streamItem as? VStream {
            navigate(toStream: stream, atStreamItem: nil)
        }
    }
    
    private func showContentView(forCellEvent event: StreamCellContext, trackingInfo info: [String : AnyObject], previewImage image: UIImage) {
        
        if let streamItem = event.streamItem as? VSequence {
            let streamID = ( event.stream.hasShelfID() && event.fromShelf ) ? event.stream.shelfId : event.stream.streamId
            
            VContentViewPresenter.presentContentViewFromViewController(
                self, withDependencyManager: dependencyManager,
                forSequence: event.streamItem as? VSequence,
                inStreamWithID: streamID,
                commentID: nil,
                withPreviewImage: image
            )
        }
    }
}
