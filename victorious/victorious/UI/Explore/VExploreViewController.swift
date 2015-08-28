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
class VExploreViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout, VMarqueeDataDelegate, VMarqueeSelectionDelegate {
    
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var collectionView: UICollectionView!

    /// The dependencyManager that is used to manage dependencies of explore screen
    private(set) var dependencyManager: VDependencyManager?
    private let numberOfSectionsInCollectionView = 3
    private var marqueeFactory: VMarqueeCellFactory?
    private var marqueeShelf: Shelf?
    
    private struct Constants {
        let sequenceIDKey = "sequenceID"
        let marqueeDestinationDirectory = "destionationDirectory"
    }
    
    /// MARK: - View Controller Initialization
    
    class func new( #dependencyManager: VDependencyManager ) -> VExploreViewController {
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        if let exploreVC = storyboard.instantiateInitialViewController() as? VExploreViewController {
            exploreVC.dependencyManager = dependencyManager
            exploreVC.marqueeFactory = VMarqueeCellFactory(dependencyManager: dependencyManager)
            return exploreVC
        }
        fatalError("Failed to instantiate an explore view controller!")
    }
    
    /// MARK: - View Controller LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.v_supplementaryHeaderView = searchBar
        
        automaticallyAdjustsScrollViewInsets = false;
        extendedLayoutIncludesOpaqueBars = true;
        
        marqueeFactory?.registerCellsWithCollectionView(self.collectionView)
        marqueeFactory?.marqueeController?.setSelectionDelegate(self)
        marqueeFactory?.marqueeController?.setDataDelegate(self)
        
        VObjectManager.sharedManager().getExplore({ (op, obj, results) -> Void in
            if let stream = results.last as? VStream {
                for (index, streamItem) in enumerate(stream.streamItems) {
                    if let newShelf = streamItem as? Shelf {
                        self.marqueeShelf = newShelf
                        break
                    }
                }
                self.collectionView.reloadData()
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
            numberOfRows = 1
        case 1:
            numberOfRows = 3
        case 2:
            numberOfRows = 12
        default:
            fatalError("Unexpected number of sections in collection view")
        }
        
        return numberOfRows
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            if let shelf = marqueeShelf {
                if let marqueeCell = marqueeFactory?.collectionView(collectionView, cellForStreamItem: shelf, atIndexPath: indexPath) {
                    return marqueeCell
                }
            }

        default:
            if let placeHolderCell = collectionView.dequeueReusableCellWithReuseIdentifier("placeHolder", forIndexPath: indexPath) as? UICollectionViewCell {
                return placeHolderCell
            }
        }
        return collectionView.dequeueReusableCellWithReuseIdentifier("placeHolder", forIndexPath: indexPath) as! UICollectionViewCell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return numberOfSectionsInCollectionView
    }
    
    /// MARK: - UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if let searchVC = VUsersAndTagsSearchViewController.newWithDependencyManager(dependencyManager) {
            v_navigationController().innerNavigationController.pushViewController(searchVC, animated: true)
        }
    }
    
    /// MARK: - MarqueeDataDelegate
    
    func marquee(marquee: VAbstractMarqueeController!, reloadedStreamWithItems streamItems: [AnyObject]!) {
        
    }
    
    ///MARK: - MarqueeSelectionDelegate
    func marquee(marquee: VAbstractMarqueeController!, selectedItem streamItem: VStreamItem!, atIndexPath path: NSIndexPath!, previewImage image: UIImage) {
        if let cell = marquee.collectionView.cellForItemAtIndexPath(path) {
            navigate(toStreamItem: streamItem, fromStream: marquee.shelf, withPreviewImage: image, inCell: cell)
        }
        else {
            fatalError("Unable to create a collection view cell")
        }
    }
    
    func navigate(toStream stream: VStream, atStreamItem streamItem: VStreamItem?) {
        let isShelf = stream.isShelf
        if stream.isSingleStream || isShelf {
            var streamCollection: VStreamCollectionViewController?
            
            let baseDict = [Constants().sequenceIDKey : stream.remoteId]
            var config = NSMutableDictionary(dictionary: baseDict)
            if let name = stream.name {
                config[VDependencyManagerTitleKey] = name
            }
            
            if isShelf {
                config[VStreamCollectionViewControllerStreamURLKey] = stream.apiPath
                if let childDependencyManager = self.dependencyManager?.childDependencyManagerWithAddedConfiguration(config as [NSObject : AnyObject]) {
                    if let tagShelf = stream as? HashtagShelf {
                        streamCollection = childDependencyManager.hashtagStreamWithHashtag(tagShelf.hashtagTitle)
                    }
                    else {
                        streamCollection = VStreamCollectionViewController.newWithDependencyManager(childDependencyManager)
                    }
                }
            }
            else {
                if let childDependencyManager = self.dependencyManager?.childDependencyManagerWithAddedConfiguration(config as [NSObject : AnyObject]) {
                    streamCollection = VStreamCollectionViewController.newWithDependencyManager(childDependencyManager)
                }
            }
            
            streamCollection?.currentStream = stream
            streamCollection?.targetStreamItem = streamItem
            if let streamViewController = streamCollection {
                navigationController?.pushViewController(streamViewController, animated: true)
            }
        }
        else if stream.isStreamOfStreams {
            if let directory = dependencyManager?.templateValueOfType(
                VDirectoryCollectionViewController.self,
                forKey: Constants().marqueeDestinationDirectory ) as? VDirectoryCollectionViewController {
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
                return
            }
        }
    }
    
    func navigate(toStreamItem streamItem: VStreamItem, fromStream stream: VStream, withPreviewImage image: UIImage, inCell cell: UICollectionViewCell) {
        /// Marquee item selection tracking
        let params = [ VTrackingKeyName : streamItem.name ?? "",
            VTrackingKeyRemoteId : streamItem.remoteId ?? ""]
        
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectItemFromMarquee, parameters: params)
        
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
        else if streamItem is VStream {
            if let stream = streamItem as? VStream {
                navigate(toStream: stream, atStreamItem: nil)
            }
        }
    }
    
    func showContentView(forCellEvent event: StreamCellContext, trackingInfo info: [String : AnyObject], previewImage image: UIImage) {
        
        if let streamItem = event.streamItem as? VSequence {
            let streamID = event.stream.hasShelfID() && event.fromShelf ? event.stream.shelfId : event.stream.streamId
            
            VContentViewPresenter.presentContentViewFromViewController(self, withDependencyManager: dependencyManager, forSequence: event.streamItem as? VSequence, inStreamWithID: streamID, commentID: nil, withPreviewImage: image)
        }
    }
    
    /// MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            if let shelf = marqueeShelf {
                if let size = marqueeFactory?.sizeWithCollectionViewBounds(collectionView.bounds, ofCellForStreamItem: shelf) {
                    return size
                }
            }
        default:
            return CGSizeMake(collectionView.bounds.width, 100)
        }
        return CGSizeMake(collectionView.bounds.width, 100)
    }
}