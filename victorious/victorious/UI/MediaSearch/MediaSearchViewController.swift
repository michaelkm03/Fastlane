//
//  MediaSearchViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import MBProgressHUD
import UIKit

/// Delegate that handles events that originate from within a `MediaSearchViewController`
@objc protocol MediaSearchDelegate {
    
    /// The user selected a search result and wants to proceed with it in a creation flow.
    func mediaSearchResultSelected( selectedMediaSearchResult: MediaSearchResult )
    
    /// The user did not select a search result and wants to exit this view
    optional func mediaSearchDidCancel()
}

class MediaSearchOptions: NSObject {
    var showPreview: Bool = false
    var showAttribution: Bool = false
    var clearSelectionOnAppearance: Bool = false
    var shouldSkipExportRendering: Bool = false
    
    static var defaultOptions: MediaSearchOptions {
        return MediaSearchOptions()
    }
}

/// View controller that allows users to search for media files as part of a content creation flow.
class MediaSearchViewController: UIViewController, UISearchBarDelegate, VPaginatedDataSourceDelegate, LoadingCancellableViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var options: MediaSearchOptions {
        return self.dataSourceAdapter.dataSource?.options ?? MediaSearchOptions()
    }
    
    private var hasLoadedOnce = false
    
    var selectedIndexPath: NSIndexPath?
    var previewSection: Int?
    var isScrollViewDecelerating = false
    private(set) var dependencyManager: VDependencyManager?
    
    private(set) var scrollPaginator = ScrollPaginator()
    let dataSourceAdapter = MediaSearchDataSourceAdapter()
    private var mediaExporter: MediaSearchExporter?
    
    weak var delegate: MediaSearchDelegate?
    
    class func mediaSearchViewController( dataSource dataSource: MediaSearchDataSource, dependencyManager: VDependencyManager ) -> MediaSearchViewController {
        
        let bundle = UIStoryboard(name: "MediaSearch", bundle: nil)
        if let viewController = bundle.instantiateInitialViewController() as? MediaSearchViewController {
            viewController.dependencyManager = dependencyManager
            viewController.dataSourceAdapter.dataSource = dataSource
            dataSource.delegate = viewController
            return viewController
        }
        fatalError( "Could not load MediaSearchViewController from storyboard." )
    }
    
    private var progressHUD: MBProgressHUD?
    
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.accessibilityIdentifier = AutomationId.MediaSearchCollection.rawValue
        
        scrollPaginator.loadItemsBelow = { [weak self] in
            // No need to pass in a search term, the data sources know how to discern based
            // on the search term of the previous page.
            self?.performSearch(searchTerm: nil, pageType: .Next)
        }
        
        self.searchBar.delegate = self
        self.searchBar.accessibilityIdentifier = AutomationId.MediaSearchSearchbar.rawValue
        if let searchTextField = self.searchBar.v_textField {
            searchTextField.tintColor = self.dependencyManager?.colorForKey(VDependencyManagerLinkColorKey)
            searchTextField.font = self.dependencyManager?.fontForKey(VDependencyManagerHeading4FontKey)
            searchTextField.textColor = UIColor.whiteColor()
            searchTextField.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        }
        
        self.collectionView.dataSource = self.dataSourceAdapter
        self.collectionView.delegate = self
        self.searchBar.placeholder = NSLocalizedString( "Search", comment:"" )
        
        self.navigationItem.titleView = self.titleViewWithTitle( self.dataSourceAdapter.dataSource?.title ?? "" )
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Next", comment: ""),
            style: .Plain,
            target: self,
            action: #selector(continueWithSelectedItem(_: ))
        )
        
        // Load with no search term for default results (determined by data sources)
        self.performSearch(searchTerm: nil)
        
        self.updateNavigationItemState()
        
        // Only modify the left navigaiton item if we are the root of the nav stack
        if self.navigationController?.viewControllers.first == self {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .Plain,
                target: self,
                action: #selector(cancel)
            )
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.options.clearSelectionOnAppearance {
            collectionView?.selectItemAtIndexPath(nil, animated: true, scrollPosition: .None)
        }
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func cancel() {
        progressHUD?.hide(true)
        self.mediaExporter?.cancelDownload()
        delegate?.mediaSearchDidCancel?()
    }
    
    // MARK: - API
    
    func continueWithSelectedItem(sender: AnyObject?) {
        guard let indexPath = self.selectedIndexPath else {
            return
        }
        
        let mediaSearchResultObject = self.dataSourceAdapter.sections[ indexPath.section ][ indexPath.row ]
        
        if options.shouldSkipExportRendering {
            if let thumbnailImageURL = mediaSearchResultObject.thumbnailImageURL {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { [weak self] in
                    if let previewImageData = try? NSData(contentsOfURL: thumbnailImageURL, options: []) {
                        mediaSearchResultObject.exportPreviewImage = UIImage(data: previewImageData)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.delegate?.mediaSearchResultSelected( mediaSearchResultObject )
                    }
                }
            }
        } else {
            exportMedia(fromSearchResult: mediaSearchResultObject)
        }
    }
    
    func exportMedia(fromSearchResult mediaSearchResultObject: MediaSearchResult) {
        guard let view = NSBundle.mainBundle().loadNibNamed("LoadingCancellableView", owner: self, options: nil)?.first as? LoadingCancellableView else {
            return
        }
        view.delegate = self
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
        progressHUD = MBProgressHUD.showHUDAddedTo( self.view.window, animated: true )
        progressHUD?.mode = MBProgressHUDMode.CustomView
        progressHUD?.customView = view
        progressHUD?.square = true;
        progressHUD?.dimBackground = true
        progressHUD?.show(true)
        
        self.mediaExporter?.cancelDownload()
        self.mediaExporter = nil
        
        let mediaExporter = MediaSearchExporter(mediaSearchResult: mediaSearchResultObject)
        mediaExporter.loadMedia() { [weak self] (previewImage, mediaURL, error) in
            dispatch_after(0.5) {
                guard let strongSelf = self where !mediaExporter.cancelled else {
                    return
                }
                strongSelf.progressHUD?.hide(true)
                if let previewImage = previewImage, let mediaURL = mediaURL {
                    mediaSearchResultObject.exportPreviewImage = previewImage
                    mediaSearchResultObject.exportMediaURL = mediaURL
                    strongSelf.delegate?.mediaSearchResultSelected( mediaSearchResultObject )
                } else {
                    strongSelf.progressHUD?.hide(true)
                    strongSelf.showHud(renderingError: error)
                }
            }
        }
        self.mediaExporter = mediaExporter
    }
    
    private func showHud(renderingError error: NSError?) {
        if error?.code != NSURLErrorCancelled {
            MBProgressHUD.hideAllHUDsForView(view, animated: false)
            let errorTitle = NSLocalizedString("Error rendering media", comment: "")
            v_showErrorWithTitle(errorTitle, message: "")
        }
    }
    
    func selectCellAtSelectedIndexPath() {
        if let indexPath = self.selectedIndexPath {
            collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
    }
    
    func performSearch( searchTerm searchTerm: String?, pageType: VPageType = .First ) {
        if self.dataSourceAdapter.state != .Loading {
            self.dataSourceAdapter.performSearch( searchTerm: searchTerm, pageType: pageType ) { result in
                self.updateViewWithResult( result )
                self.reloadNoContentSection()
                self.hasLoadedOnce = true
            }
            if hasLoadedOnce {
                reloadNoContentSection()
            }
        }
    }
    
    func reloadNoContentSection() {
        /// The no content cell is only visible when the data source's sections are empty
        guard self.dataSourceAdapter.sections.isEmpty else {
            return
        }
        
        // Now reload the no content cell's section so that it is accurately reflecting
        //  the current state of the paginated data source
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadSections( NSIndexSet(index: 0) )
            }, completion: nil)
    }
    
    func updateViewWithResult( result: MediaSearchDataSourceAdapter.ChangeResult? ) {
        if let result = result where result.hasChanges {
            self.collectionView.performBatchUpdates({
                self.collectionView.applyDataSourceChanges( result )
                }, completion: nil)
        }
        if result?.error != nil || (result?.hasChanges == false && (self.dataSourceAdapter.dataSource?.visibleItems.count ?? 0) == 0) {
            self.collectionView.reloadData()
        }
    }
    
    func clearSearch() {
        self.collectionView.performBatchUpdates({
            let result = self.dataSourceAdapter.clear()
            self.collectionView.applyDataSourceChanges( result )
            }, completion: nil)
        
        self.selectedIndexPath = nil
        self.previewSection = nil
        self.collectionView.setContentOffset( CGPoint.zero, animated: false )
        self.updateLayout()
    }
    
    private func titleViewWithTitle( text: String ) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = UIFont.preferredFontForTextStyle( UIFontTextStyleHeadline )
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        return label
    }
    
    private func updateNavigationItemState() {
        self.navigationItem.rightBarButtonItem?.enabled = selectedIndexPath != nil
        self.navigationItem.rightBarButtonItem?.accessibilityIdentifier = AutomationId.MediaSearchNext.rawValue
    }
    
    /// Inserts a new section into the collection view that shows a fullsize preview video for the search result
    func showPreviewForResult( indexPath: NSIndexPath ) {
        var sectionInserted: Int?
        
        self.collectionView.performBatchUpdates({
            let result = self.dataSourceAdapter.addHighlightSection(forIndexPath: indexPath)
            sectionInserted = result.insertedSections?.indexGreaterThanIndex(0)
            self.collectionView.applyDataSourceChanges( result )
            }, completion: nil)
        
        if let sectionInserted = sectionInserted {
            let previewCellIndexPath = NSIndexPath(forRow: 0, inSection: sectionInserted)
            if let cell = self.collectionView.cellForItemAtIndexPath( previewCellIndexPath ) {
                self.collectionView.sendSubviewToBack( cell )
            }
            self.selectedIndexPath = NSIndexPath(forRow: indexPath.row, inSection: sectionInserted - 1)
            self.previewSection = sectionInserted
            
            self.collectionView.scrollToItemAtIndexPath( previewCellIndexPath,
                                                         atScrollPosition: .CenteredVertically,
                                                         animated: true )
            
            self.updateLayout()
        }
        
        self.updateNavigationItemState()
    }
    
    /// Invalidates the layout through a batch update so layout changes are animated
    private func updateLayout() {
        self.collectionView.performBatchUpdates({
            self.collectionView.collectionViewLayout.invalidateLayout()
            }, completion: nil )
    }
    
    /// Removes the section showing a search result preview at the specified index path
    func hidePreviewForResult( indexPath: NSIndexPath ) {
        self.collectionView.performBatchUpdates({
            let result = self.dataSourceAdapter.removeHighlightSection()
            self.collectionView.applyDataSourceChanges( result )
            }, completion: nil )
        
        self.selectedIndexPath = nil
        self.previewSection = nil
        
        self.collectionView.performBatchUpdates({
            self.collectionView.collectionViewLayout.invalidateLayout()
            }, completion: nil )
        
        self.updateNavigationItemState()
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text where searchTerm.characters.count > 0 else {
            return
        }
        self.clearSearch()
        self.performSearch(searchTerm: searchTerm)
        searchBar.resignFirstResponder()
    }
    
    // MARK: - VPaginatedDataSourceDelegate
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: VDataSourceState, to newState: VDataSourceState) {
        if hasLoadedOnce {
            self.updateLayout()
        }
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        // `MediaSearchDataSourceAdapter` handles errors in its own unique way
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didReceiveError error: NSError) {
        // `MediaSearchDataSourceAdapter` handles errors in its own unique way
    }
}

/// Conveninece method to insert/delete sections during a batch update
private extension UICollectionView {
    
    /// Inserts or deletes sections according to the inserted and deleted sections indicated in the result
    ///
    /// - parameter result: A `MediaSearchDataSourceAdapter.ChangeResult` that contains info about which sections to insert or delete
    func applyDataSourceChanges( result: MediaSearchDataSourceAdapter.ChangeResult ) {
        
        if let insertedSections = result.insertedSections {
            self.insertSections( insertedSections )
        }
        if let deletedSections = result.deletedSections {
            self.deleteSections( deletedSections )
        }
    }
}
