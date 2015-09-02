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
class VExploreViewController: VAbstractStreamCollectionViewController, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {
    
    private struct Constants {
        static let sequenceIDKey = "sequenceID"
        static let marqueeDestinationDirectory = "destionationDirectory"
        static let trendingTopicShelfKey = "trendingTopics"
        static let destinationStreamKey = "destinationStream"
        
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
    private let failureCellFactory: VNoContentCollectionViewCellFactory = VNoContentCollectionViewCellFactory(acceptableContentClasses: nil)
    private var marqueeShelfFactory: VMarqueeCellFactory?
    
    /// The dependencyManager that is used to manage dependencies of explore screen
    private(set) var dependencyManager: VDependencyManager?
    
    private struct SectionRange {
        let range: NSRange
        let isShelf: Bool
        
        init(range: NSRange, isShelf: Bool) {
            self.range = range
            self.isShelf = isShelf
        }
    }
    
    private var sectionRanges = [SectionRange]()
    
    /// MARK: - View Controller Initialization
    
    class func new( #dependencyManager: VDependencyManager ) -> VExploreViewController {
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        if let exploreVC = storyboard.instantiateInitialViewController() as? VExploreViewController {
            exploreVC.dependencyManager = dependencyManager
            let url = dependencyManager.stringForKey(VStreamCollectionViewControllerStreamURLKey);
            let urlPath = url.v_pathComponent()
            exploreVC.currentStream = VStream(forPath: urlPath, inContext: dependencyManager.objectManager().managedObjectStore.mainQueueManagedObjectContext)
            // Factory for marquee shelf
            exploreVC.marqueeShelfFactory = VMarqueeCellFactory(dependencyManager: dependencyManager)
            // Factory for trending topic shelf
            exploreVC.trendingTopicShelfFactory = dependencyManager.templateValueOfType(TrendingTopicShelfFactory.self, forKey: Constants.trendingTopicShelfKey) as? TrendingTopicShelfFactory
            exploreVC.streamShelfFactory = VStreamContentCellFactory(dependencyManager: dependencyManager)
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
        
        marqueeShelfFactory?.registerCellsWithCollectionView(collectionView)
        marqueeShelfFactory?.marqueeController?.setSelectionDelegate(self)
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
    
    /// Mark: - UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if let searchVC = VUsersAndTagsSearchViewController .newWithDependencyManager(dependencyManager) {
            v_navigationController().innerNavigationController.pushViewController(searchVC, animated: true)
        }
    }
}

extension VExploreViewController : VStreamCollectionDataDelegate {
    
    override func dataSource(dataSource: VStreamCollectionViewDataSource!, cellForIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let streamItem = streamItemFor(indexPath)
        if let shelf = streamItem as? Shelf {
            
            // Trending topic shelf
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
                    if let cell = streamShelfFactory?.collectionView(collectionView, cellForStreamItem: shelf, atIndexPath: indexPath) {
                        return cell
                    }
                }
            }
        }
        else if let streamItem = streamItem {
            //Try to create a "recent content" cell
            let identifier = VShelfContentCollectionViewCell.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager)
            if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath:indexPath) as? VShelfContentCollectionViewCell {
                cell.streamItem = streamItem
                cell.dependencyManager = dependencyManager
                return cell
            }
        }
        return failureCellFactory.noContentCellForCollectionView(collectionView, atIndexPath: indexPath)
    }
    
    override func dataSource(dataSource: VStreamCollectionViewDataSource!, hasNewStreamItems streamItems: [AnyObject]!) {
        if let streamItems = streamItems as? [VStreamItem] {
            let recentItems = streamItems.filter({$0.itemType != "shelf"})
            for streamItem in recentItems {
                let identifier = VShelfContentCollectionViewCell.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager)
                collectionView.registerClass(VShelfContentCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
            }
        }
        updateSectionRanges()
    }
    
    private func updateSectionRanges() {
        if let streamItems = currentStream.streamItems.array as? [VStreamItem] {
            var recentSectionLength = 0
            var rangeIndex = 0
            for streamItem in streamItems {
                if streamItem.itemType == "shelf" {
                    if recentSectionLength != 0 {
                        //Create a new section range for the section that just ended
                        let rangeStart = streamItemIndexFor(NSIndexPath(forRow: 0, inSection: rangeIndex))
                        let sectionRange = SectionRange(range: NSMakeRange(rangeStart, recentSectionLength), isShelf: false)
                        add(sectionRange, atIndex: rangeIndex)
                        recentSectionLength = 0
                        rangeIndex++
                    }
                    let rangeStart = streamItemIndexFor(NSIndexPath(forRow: 0, inSection: rangeIndex))
                    let sectionRange = SectionRange(range: NSMakeRange(rangeStart, 1), isShelf: true)
                    add(sectionRange, atIndex: rangeIndex)
                    rangeIndex++
                }
                else {
                    //Add to existing recent section
                    recentSectionLength += 1
                    if streamItem == streamItems.last {
                        //Create a new section range for the section that just ended
                        let rangeStart = streamItemIndexFor(NSIndexPath(forRow: recentSectionLength - 1, inSection: rangeIndex))
                        let sectionRange = SectionRange(range: NSMakeRange(rangeStart, recentSectionLength), isShelf: false)
                        add(sectionRange, atIndex: rangeIndex)
                    }
                }
            }
        }
    }
    
    private func add(sectionRange: SectionRange, atIndex index:Int) {
        if index < sectionRanges.count {
            sectionRanges[index] = sectionRange
        }
        else {
            sectionRanges.append(sectionRange)
        }
    }
    
    override func numberOfSectionsForDataSource(dataSource: VStreamCollectionViewDataSource!) -> Int {
        // Total number of shelves plus one section for recent content
        return sectionRanges.count
    }
    
    override func dataSource(dataSource: VStreamCollectionViewDataSource!, numberOfRowsInSection section: UInt) -> Int {
        let convertedSection = Int(section)
        if convertedSection < sectionRanges.count {
            return sectionRanges[convertedSection].range.length
        }
        return 0
    }
}

extension VExploreViewController: CHTCollectionViewDelegateWaterfallLayout {
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let streamItem = streamItemFor(indexPath) {
            if let shelf = streamItem as? Shelf {
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
                        if let streamShelfFactory = streamShelfFactory {
                            return streamShelfFactory.sizeWithCollectionViewBounds(collectionView.bounds, ofCellForStreamItem: shelf)
                        }
                    }
                }
            }
            else {
                var width = collectionView.bounds.width - ( Constants.interItemSpace * 2 + Constants.recentSectionEdgeInsets.left + Constants.recentSectionEdgeInsets.right )
                width /= 2
                width = floor(width)
                return CGSize(width: width, height: recentCellHeightAt(indexPath, forCollectionViewWidth: width))
            }
        }
        return failureCellFactory.cellSizeForCollectionViewBounds(collectionView.bounds)
    }
    
    private func recentCellHeightAt(indexPath: NSIndexPath, forCollectionViewWidth width: CGFloat) -> CGFloat {
        let filter = VObjectManager.sharedManager().filterForStream(currentStream)
        /// Warning: for testing
        let perPageNumber = filter.perPageNumber.integerValue
        let pageLocation = indexPath.row % perPageNumber
        let streamItem = streamItemFor(indexPath)
        if pageLocation == 0 {
            return width * Constants.minimizedContentAspectRatio
        }
        else if pageLocation == 1 {
            return width
        }
        else if let layout = collectionView.collectionViewLayout as? CHTCollectionViewWaterfallLayout where pageLocation >= perPageNumber - 2 {
            //Need to consider the height of the bottom 2 cells to make sure they level out properly
            if let columnsAsNumbers = layout.heightsForColumnsInSection(UInt(indexPath.section)) as? [NSNumber] {
                let columnHeights = columnsAsNumbers.map({CGFloat($0.floatValue)})
                let shortColumnHeight = minElement(columnHeights)
                let tallColumnHeight = maxElement(columnHeights)
                
                if pageLocation == perPageNumber - 2 {
                    //Make sure 2nd to last cell leaves enough space for the last cell to show properly
                    var contentHeight = recentCellHeightFor(streamItem, inCollectionViewWithWidth: width)
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
        return recentCellHeightFor(streamItem, inCollectionViewWithWidth: width)
    }
    
    private func recentCellHeightFor(streamItem: VStreamItem?, inCollectionViewWithWidth width: CGFloat) -> CGFloat {
        if let sequence = streamItem as? VSequence {
            let aspectRatio = min( 1 / sequence.previewAssetAspectRatio(), Constants.maximumContentAspectRatio )
            return width * aspectRatio
        }
        else {
            //Default to 1:1 for unexpected content types
            return width
        }
    }
    
    private func streamItemIndexFor(indexPath: NSIndexPath) -> Int {
        let section = indexPath.section
        if section != 0 && section <= sectionRanges.count {
            let priorSectionRange = sectionRanges[section - 1].range
            return priorSectionRange.location + priorSectionRange.length + indexPath.row
        }
        return 0
    }
    
    private func streamItemFor(indexPath: NSIndexPath) -> VStreamItem? {
        let index = streamItemIndexFor(indexPath)
        if index < currentStream.streamItems.count {
            return currentStream.streamItems[index] as? VStreamItem
        }
        return nil
    }
    
    private func isRecentContent(section: Int) -> Bool {
        if section < sectionRanges.count {
            return !sectionRanges[section].isShelf
        }
        return false
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.interItemSpace
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.interItemSpace
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnCountForSection section: Int) -> Int {
        return isRecentContent(section) ? 2 : 1
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.interItemSpace
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let insets = super.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAtIndex: section)
        let sectionDepedentInsets = isRecentContent(section) ? Constants.recentSectionEdgeInsets : Constants.sectionEdgeInsets
        return insets + sectionDepedentInsets
    }
}

extension VExploreViewController: UICollectionViewDelegate {
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let streamItem = streamItemFor(indexPath) {
            navigate(toStream: currentStream, atStreamItem: streamItem)
        }
    }
}

extension VExploreViewController: VHashtagSelectionResponder {
    
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
        else if stream == currentStream || stream.isSingleStream {
            //Tapped on a recent post
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
