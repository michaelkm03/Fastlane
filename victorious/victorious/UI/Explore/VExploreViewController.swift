//
//  VExploreViewController.swift
//  victorious
//
//  Created by Tian Lan on 8/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit


/// View Controllers conform to this protocol to handle
/// search result navigation(e.g. tap on a user result, or hashtag result)
@objc protocol ExploreSearchResultNavigationDelegate {
    func selectedUser(user: VUser)
    func selectedHashtag(hashtag: VHashtag)
}

/// Base view controller for the explore screen that gets
/// presented when "explore" button on the tab bar is tapped
class VExploreViewController: VAbstractStreamCollectionViewController, UISearchBarDelegate {
    
    private struct Constants {
        static let sequenceIDKey = "sequenceID"
        static let marqueeDestinationDirectory = "destinationDirectory"
        static let trendingTopicShelfKey = "trendingTopics"
        static let destinationStreamKey = "destinationStream"
        static let failureReusableViewIdentifier = "failureReusableView"
        static let streamATFThresholdKey = "streamAtfViewThreshold"
        static let userHashtagSearchKey = "userHashtagSearch"
        static let searchIconImageName = "D_search_small_icon"
        static let searchClearImageName = "search_clear_icon"
        
        static let interItemSpace: CGFloat = 1
        static let sectionEdgeInsets: UIEdgeInsets = UIEdgeInsetsMake(3, 0, 3, 0)
        static let recentSectionEdgeInsets: UIEdgeInsets = UIEdgeInsetsMake(12, 11, 3, 11)
        static let minimumContentAspectRatio: CGFloat = 0.5
        static let maximumContentAspectRatio: CGFloat = 2
        static let minimizedContentAspectRatio: CGFloat = 0.5625 //9 / 16
        static let recentSectionLabelAdditionalTopInset: CGFloat = 15
    }
    
    private var trendingTopicShelfFactory: TrendingTopicShelfFactory?
    private var streamShelfFactory: VStreamContentCellFactory?
    private var marqueeShelfFactory: VMarqueeCellFactory?
    private let failureCellFactory: VNoContentCollectionViewCellFactory = VNoContentCollectionViewCellFactory(acceptableContentClasses: nil)
    private var searchController: UISearchController?
    private var searchResultsViewController: VExploreSearchResultsViewController?
    
    /// The dependencyManager that is used to manage dependencies of explore screen
    private var trackingMinRequiredCellVisibilityRatio: CGFloat = 0
    
    private let contentPresenter = ContentViewPresenter()
    
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
    
    class func new( dependencyManager dependencyManager: VDependencyManager ) -> VExploreViewController {
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        guard let exploreVC = storyboard.instantiateInitialViewController() as? VExploreViewController else {
            fatalError("Failed to instantiate an explore view controller!")
        }
        
        exploreVC.dependencyManager = dependencyManager
        let url = dependencyManager.stringForKey(VStreamCollectionViewControllerStreamURLKey);
        let urlPath = url.v_pathComponent()
        exploreVC.currentStream = VStream(forPath: urlPath, inContext: dependencyManager.objectManager().managedObjectStore.mainQueueManagedObjectContext)
        exploreVC.currentStream.name = dependencyManager.stringForKey(VDependencyManagerTitleKey)
        // Factory for marquee shelf
        exploreVC.marqueeShelfFactory = VMarqueeCellFactory(dependencyManager: dependencyManager)
        // Factory for trending topic shelf
        exploreVC.trendingTopicShelfFactory = dependencyManager.templateValueOfType(TrendingTopicShelfFactory.self, forKey: Constants.trendingTopicShelfKey) as? TrendingTopicShelfFactory
        exploreVC.streamShelfFactory = VStreamContentCellFactory(dependencyManager: dependencyManager)
        exploreVC.trackingMinRequiredCellVisibilityRatio = CGFloat(dependencyManager.numberForKey(Constants.streamATFThresholdKey).floatValue)
        return exploreVC
    }
    
    /// MARK: - View Controller LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchBar()
        collectionView.backgroundColor = UIColor.whiteColor()
        marqueeShelfFactory?.registerCellsWithCollectionView(collectionView)
        marqueeShelfFactory?.marqueeController?.setSelectionDelegate(self)
        trendingTopicShelfFactory?.registerCellsWithCollectionView(collectionView)
        streamShelfFactory?.registerCellsWithCollectionView(collectionView)
        failureCellFactory.registerNoContentCellWithCollectionView(collectionView)
        collectionView.registerClass(RecentPostsExploreHeaderView.self, forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: RecentPostsExploreHeaderView.suggestedReuseIdentifier())
        collectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: Constants.failureReusableViewIdentifier)
        collectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Constants.failureReusableViewIdentifier)
        collectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: CHTCollectionElementKindSectionFooter, withReuseIdentifier: Constants.failureReusableViewIdentifier)
        collectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: Constants.failureReusableViewIdentifier)
        
        if let dataSource = streamDataSource {
            dataSource.stream = currentStream
            dataSource.delegate = self
            collectionView.dataSource = dataSource
        }
        
        collectionView.backgroundColor = UIColor.clearColor()
        definesPresentationContext = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        v_navigationController().view.setNeedsLayout()
        searchResultsViewController?.updateTableView()
    }
    
    override func dataSource(dataSource: VStreamCollectionViewDataSource, cellForIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let streamItem = streamItemFor(indexPath)
        if let shelf = streamItem as? Shelf {
            
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
        else if let sequence = streamItem as? VSequence {
            //Try to create a "recent content" cell
            let identifier = VShelfContentCollectionViewCell.reuseIdentifierForStreamItem(sequence, baseIdentifier: nil, dependencyManager: dependencyManager)
            if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath:indexPath) as? VShelfContentCollectionViewCell {
                cell.dependencyManager = dependencyManager
                cell.streamItem = sequence
                return cell
            }
        }
        return failureCellFactory.noContentCellForCollectionView(collectionView, atIndexPath: indexPath)
    }
    
    override func dataSource(dataSource: VStreamCollectionViewDataSource, hasNewStreamItems streamItems: [AnyObject] ) {
        if let streamItems = streamItems as? [VStreamItem] {
            let recentItems = streamItems.filter({$0.itemType != VStreamItemTypeShelf})
            for streamItem in recentItems {
                let identifier = VShelfContentCollectionViewCell.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager)
                collectionView.registerClass(VShelfContentCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
            }
        }
        updateSectionRanges()
        trackVisibleCells()
    }
    
    private func updateSectionRanges() {
        var tempRanges = [SectionRange]()
        if let streamDataSource = streamDataSource, let streamItems = streamDataSource.visibleStreamItems.array as? [VStreamItem] {
            var recentSectionLength = 0
            var rangeIndex = 0
            for streamItem in streamItems {
                if streamItem.itemType == VStreamItemTypeShelf {
                    if recentSectionLength != 0 {
                        //Create a new section range for the section that just ended
                        let rangeStart = streamItemIndexFor(NSIndexPath(forRow: 0, inSection: rangeIndex), inRanges:tempRanges)
                        let sectionRange = SectionRange(range: NSMakeRange(rangeStart, recentSectionLength), isShelf: false)
                        add(sectionRange, toRanges:&tempRanges, atIndex: rangeIndex)
                        recentSectionLength = 0
                        rangeIndex++
                    }
                    let rangeStart = streamItemIndexFor(NSIndexPath(forRow: 0, inSection: rangeIndex), inRanges:tempRanges)
                    let sectionRange = SectionRange(range: NSMakeRange(rangeStart, 1), isShelf: true)
                    add(sectionRange, toRanges:&tempRanges, atIndex: rangeIndex)
                    rangeIndex++
                }
                else {
                    //Add to existing recent section
                    recentSectionLength += 1
                    if streamItem == streamItems.last {
                        //Create a new section range for the section that just ended
                        let rangeStart = streamItemIndexFor(NSIndexPath(forRow: 0, inSection: rangeIndex), inRanges:tempRanges)
                        let sectionRange = SectionRange(range: NSMakeRange(rangeStart, recentSectionLength), isShelf: false)
                        add(sectionRange, toRanges:&tempRanges, atIndex: rangeIndex)
                    }
                }
            }
        }
        sectionRanges = tempRanges
    }
    
    private func add(sectionRange: SectionRange, inout toRanges ranges: [SectionRange], atIndex index:Int) {
        if index < ranges.count {
            ranges[index] = sectionRange
        }
        else {
            ranges.append(sectionRange)
        }
    }
    
    override func hasEnoughItemsToShowLoadingIndicatorFooterInSection(section: Int) -> Bool {
        // Always return YES for our empty last section containing the footer
        return section == collectionView.numberOfSections() - 1
    }
    
    override func numberOfSectionsForDataSource(dataSource: VStreamCollectionViewDataSource) -> Int {
        // Total number of shelves plus one section for recent content
        return sectionRanges.count + 1
    }
    
    override func dataSource(dataSource: VStreamCollectionViewDataSource, numberOfRowsInSection section: UInt) -> Int {
        let convertedSection = Int(section)
        if convertedSection < sectionRanges.count {
            return sectionRanges[convertedSection].range.length
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == CHTCollectionElementKindSectionHeader {
            if let header = collectionView.dequeueReusableSupplementaryViewOfKind(CHTCollectionElementKindSectionHeader, withReuseIdentifier: RecentPostsExploreHeaderView.suggestedReuseIdentifier(), forIndexPath: indexPath) as? RecentPostsExploreHeaderView {
                header.dependencyManager = dependencyManager
                return header
            }
        }
        // Return a proper view for unexpected supplementary views to avoid crashes
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Constants.failureReusableViewIdentifier, forIndexPath: indexPath)
    }
    
    override func shouldDisplayActivityViewFooterForCollectionView(collectionView: UICollectionView, inSection section: Int) -> Bool {
        // Only show activity footer if the superclass's checks, which check for being able to load more items from the stream,
        // pass and we're trying to display a footer in the last section of the collection view
        return super.shouldDisplayActivityViewFooterForCollectionView(collectionView, inSection: section) && section == collectionView.numberOfSections() - 1
    }
    
    /// MARK: Tracking
    
    private func trackVisibleCells() {
        dispatch_after(0.1) {
            for cell in self.collectionView.visibleCells() {
                if let cell = cell as? TrendingTopicShelfCollectionViewCell {
                    cell.streamItemVisibilityTrackingHelper.trackVisibleSequences()
                }
                else if let cell = cell as? VShelfContentCollectionViewCell {
                    self.updateTrackingFor(cell)
                }
            }
            if let marqueeController = self.marqueeShelfFactory?.marqueeController as? VAbstractMarqueeController {
                marqueeController.updateCellVisibilityTracking()
            }
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        trackVisibleCells()
    }
    
    private func updateTrackingFor(recentPostCell: VShelfContentCollectionViewCell) {
        if let sequence = recentPostCell.sequenceToTrack() {
            let intersection = self.collectionView.bounds.intersect(recentPostCell.frame)
            let visibilityRatio = intersection.height / recentPostCell.frame.height
            if visibilityRatio > trackingMinRequiredCellVisibilityRatio {
                let event = StreamCellContext(streamItem: sequence, stream: currentStream, fromShelf: false)
                streamTrackingHelper.onStreamCellDidBecomeVisibleWithCellEvent(event)
            }
        }
    }
    
    /// MARK: Search bar management
    
    private func configureSearchBar() {
        // Initialize searchResultsViewController and searchController
        guard let dependencyManager = self.dependencyManager,
              let searchConfiguration = dependencyManager.templateValueOfType(NSDictionary.self, forKey: Constants.userHashtagSearchKey) as? [NSObject : AnyObject],
              let searchDependencyManager = dependencyManager.childDependencyManagerWithAddedConfiguration(searchConfiguration) else {
                return
        }
        
        searchResultsViewController = VExploreSearchResultsViewController.newWithDependencyManager(searchDependencyManager)
        searchResultsViewController?.navigationDelegate = self
        searchController = UISearchController(searchResultsController: searchResultsViewController)

        // Configure searchController properties
        guard let searchController = searchController else {
            return
        }
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        
        // Configure searchBar properties
        let searchBar = searchController.searchBar
        searchBar.sizeToFit()
        searchBar.delegate = searchResultsViewController
        searchBar.tintColor = dependencyManager.textColor
        navigationItem.titleView = searchBar
        
        // Configure appearance of search text field
        guard let searchTextField = searchBar.v_textField else {
            return
        }
        
        searchTextField.font = dependencyManager.textFont
        searchTextField.textColor = dependencyManager.textColor
        searchTextField.backgroundColor = dependencyManager.backgroundColor
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("Search people and hashtags", comment: ""),
            attributes: [NSForegroundColorAttributeName: dependencyManager.placeHolderColor]
        )
        
        // Set tinted image for magnifying glass icon and clear button
        
        // Made 2 UIImage instances with the same image asset because we cannot
        // set the same instance for .Highlight and .Normal
        guard var searchIconImage = UIImage(named: Constants.searchIconImageName),
              var searchClearImageHighlighted = UIImage(named: Constants.searchClearImageName),
              var searchClearImageNormal = UIImage(named: Constants.searchClearImageName) else {
                return
        }

        searchIconImage = searchIconImage.v_tintedTemplateImageWithColor(dependencyManager.placeHolderColor)
        searchBar.setImage(searchIconImage, forSearchBarIcon: .Search, state: .Normal)
        
        searchClearImageHighlighted = searchClearImageHighlighted.v_tintedTemplateImageWithColor(dependencyManager.placeHolderColor)
        searchBar.setImage(searchClearImageHighlighted, forSearchBarIcon: .Clear, state: .Highlighted)
        
        searchClearImageNormal = searchClearImageNormal.v_tintedTemplateImageWithColor(dependencyManager.placeHolderColor)
        searchBar.setImage(searchClearImageNormal, forSearchBarIcon: .Clear, state: .Normal)
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
}

private extension VDependencyManager {
    
    var textFont: UIFont {
        return fontForKey(VDependencyManagerLabel3FontKey)
    }
    
    var textColor: UIColor {
        return colorForKey(VDependencyManagerSecondaryTextColorKey)
    }
    
    var backgroundColor: UIColor {
        return colorForKey(VDependencyManagerSecondaryAccentColorKey)
    }
    
    var placeHolderColor: UIColor {
        return colorForKey(VDependencyManagerPlaceholderTextColorKey)
    }
}

extension VExploreViewController { //UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForHeaderInSection section: Int) -> CGFloat {
        if let dependencyManager = dependencyManager where isRecentContent(section) {
            return RecentPostsExploreHeaderView.desiredHeight(dependencyManager)
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForFooterInSection section: Int) -> CGFloat {
        if section == collectionView.numberOfSections() - 1 {
            // We're in our dummy last section, return the preffered size for the activity indicator footer
            return super.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section).height
        }
        return 0
    }
    
    private func recentCellHeightAt(indexPath: NSIndexPath, forCollectionViewWidth width: CGFloat) -> CGFloat {
        let filter = VObjectManager.sharedManager().filterForStream(currentStream)
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
            guard let columnsAsNumbers = layout.heightsForColumnsInSection(UInt(indexPath.section)) as? [NSNumber] else {
                return 0
            }
            let columnHeights = columnsAsNumbers.map({CGFloat($0.floatValue)})
            guard let shortColumnHeight = columnHeights.minElement(), tallColumnHeight = columnHeights.maxElement() else {
                return 0
            }
            if pageLocation == perPageNumber - 2 {
                //Make sure 2nd to last cell leaves enough space for the last cell to show properly
                let contentHeight = recentCellHeightFor(streamItem, inCollectionViewWithWidth: width)
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
    
    private func streamItemIndexFor(indexPath: NSIndexPath, inRanges ranges: [SectionRange]? = nil) -> Int {
        let section = indexPath.section
        var rangesToSearch = sectionRanges
        if let ranges = ranges {
            rangesToSearch = ranges
        }
        if section <= rangesToSearch.count {
            if section != 0 {
                let priorSectionRange = rangesToSearch[section - 1].range
                return priorSectionRange.location + priorSectionRange.length + indexPath.row
            }
            else {
                return indexPath.row
            }
        }
        return 0
    }
    
    private func streamItemFor(indexPath: NSIndexPath) -> VStreamItem? {
        let index = streamItemIndexFor(indexPath)
        if let streamDataSource = streamDataSource where index < streamDataSource.visibleStreamItems.count {
            return streamDataSource.visibleStreamItems[index] as? VStreamItem
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.interItemSpace
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let numberOfSections = collectionView.numberOfSections()
        if section == numberOfSections - 1 {
            //Dealing with the last, dummy section that will show the activity indicator if there's more pages to load
            return UIEdgeInsetsZero
        }
        
        let insets = super.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAtIndex: section)
        var sectionDependentInsets = isRecentContent(section) ? Constants.recentSectionEdgeInsets : Constants.sectionEdgeInsets
        if isRecentContent(section + 1) {
            sectionDependentInsets.bottom += Constants.recentSectionLabelAdditionalTopInset
        }
        if section == 0 {
            sectionDependentInsets.top = 0
        }
        if numberOfSections > 1 && section == numberOfSections - 2 {
            sectionDependentInsets.bottom = 0
        }
        return insets + sectionDependentInsets
    }
}

extension VExploreViewController { //UICollectionViewDelegate
    
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
    
    
    
    func marqueeController(marquee: VAbstractMarqueeController, didSelectItem streamItem: VStreamItem, withPreviewImage image: UIImage?, fromCollectionView collectionView: UICollectionView, atIndexPath path: NSIndexPath) {
        
        if let cell = marquee.collectionView.cellForItemAtIndexPath(path) {
            navigate(toStreamItem: streamItem, fromStream: marquee.shelf, withPreviewImage: image, inCell: cell)
        }
        else {
            assertionFailure("Explore View controller was unable to retrive a marquee cell at the provided index path")
        }
    }
    
    private func navigate(toStream stream: VStream, atStreamItem streamItem: VStreamItem?) {
        let isShelf = stream.isShelf
        var streamCollection: VStreamCollectionViewController?
        
        // The config dictionary here is initialized to solve objc/swift dictionary type inconsistency
        let baseDict = [Constants.sequenceIDKey : stream.remoteId]
        let configDict = NSMutableDictionary(dictionary: baseDict)
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
            if let streamDataSource = streamCollection?.streamDataSource {
                streamDataSource.suppressShelves = stream == currentStream
            }
        }
        
        // show the stream view controller if it has been instantiated
        if let streamViewController = streamCollection {
            streamViewController.currentStream = stream
            streamViewController.targetStreamItem = streamItem
            navigationController?.pushViewController(streamViewController, animated: true)
        }
        // else Show the stream of streams
        else if stream.isStreamOfStreams {
            if let directory = dependencyManager?.templateValueOfType (
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
                ).show()
            }
        }
    }
    
    private func navigate(toStreamItem streamItem: VStreamItem, fromStream stream: VStream, withPreviewImage image: UIImage?, inCell cell: UICollectionViewCell) {
        
        /// Marquee item selection tracking
        let params = [
            VTrackingKeyName : streamItem.name ?? "",
            VTrackingKeyRemoteId : streamItem.remoteId ?? ""
        ]
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectItemFromMarquee, parameters: params)
        
        let event = StreamCellContext(streamItem: streamItem, stream: stream, fromShelf: true)
        
        // Navigating to a sequence
        if let sequence = event.streamItem as? VSequence {
            let isFromShelf = event.stream.hasShelfID() && event.fromShelf
            let streamId = isFromShelf ? event.stream.shelfId : event.stream.streamId
            
            let context = ContentViewContext()
            context.originDependencyManager = dependencyManager
            context.sequence = sequence
            context.streamId = streamId
            context.placeholderImage = image
            self.contentPresenter.presentContentView(context: context)
        }
        // Navigating to a stream
        else if let stream = streamItem as? VStream {
            navigate(toStream: stream, atStreamItem: nil)
        }
    }
}

extension VExploreViewController: ExploreSearchResultNavigationDelegate {
    func selectedUser(user: VUser) {
        if let dependencyManager = self.dependencyManager {
            let viewController = dependencyManager.userProfileViewControllerWithUser(user)
            v_navigationController().innerNavigationController.pushViewController(viewController, animated: true)
        }
    }
    
    func selectedHashtag(hashtag: VHashtag) {
        if let dependencyManager = self.dependencyManager {
            let viewController = dependencyManager.hashtagStreamWithHashtag(hashtag.tag)
            v_navigationController().innerNavigationController.pushViewController(viewController, animated: true)
        }
    }
}

extension VExploreViewController: VTabMenuContainedViewControllerNavigation {
    func reselected() {
        v_navigationController().setNavigationBarHidden(false)
        collectionView.setContentOffset(CGPointZero, animated: true)
    }
}
