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
    func mediaSearchResultSelected( _ selectedMediaSearchResult: MediaSearchResult )
    
    /// The user did not select a search result and wants to exit this view
    @objc optional func mediaSearchDidCancel()
}

class MediaSearchOptions: NSObject {
    var showPreview = false
    var showAttribution = false
    var clearSelectionOnAppearance = false
    var shouldSkipExportRendering = false
    
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
    
    fileprivate var hasLoadedOnce = false
    
    var selectedIndexPath: IndexPath?
    var previewSection: Int?
    var isScrollViewDecelerating = false
    fileprivate(set) var dependencyManager: VDependencyManager?
    
    fileprivate(set) var scrollPaginator = ScrollPaginator()
    let dataSourceAdapter = MediaSearchDataSourceAdapter()
    fileprivate var mediaExporter: MediaSearchExporter?
    
    weak var delegate: MediaSearchDelegate?
    
    class func mediaSearchViewController( dataSource: MediaSearchDataSource, dependencyManager: VDependencyManager ) -> MediaSearchViewController {
        
        let bundle = UIStoryboard(name: "MediaSearch", bundle: nil)
        if let viewController = bundle.instantiateInitialViewController() as? MediaSearchViewController {
            viewController.dependencyManager = dependencyManager
            viewController.dataSourceAdapter.dataSource = dataSource
            dataSource.delegate = viewController
            return viewController
        }
        fatalError( "Could not load MediaSearchViewController from storyboard." )
    }
    
    fileprivate var progressHUD: MBProgressHUD?
    
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.accessibilityIdentifier = AutomationId.MediaSearchCollection.rawValue
        
        scrollPaginator.loadItemsBelow = { [weak self] in
            // No need to pass in a search term, the data sources know how to discern based
            // on the search term of the previous page.
            self?.performSearch(searchTerm: nil, pageType: .next)
        }
        
        self.searchBar.delegate = self
        self.searchBar.accessibilityIdentifier = AutomationId.MediaSearchSearchbar.rawValue
        if let searchTextField = self.searchBar.v_textField {
            searchTextField.tintColor = self.dependencyManager?.color(forKey: VDependencyManagerLinkColorKey)
            searchTextField.font = self.dependencyManager?.font(forKey: VDependencyManagerHeading4FontKey)
            searchTextField.textColor = UIColor.white
            searchTextField.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        }
        
        self.collectionView.dataSource = self.dataSourceAdapter
        self.collectionView.delegate = self
        self.searchBar.placeholder = NSLocalizedString( "Search", comment:"" )
        
        self.navigationItem.titleView = self.titleViewWithTitle( self.dataSourceAdapter.dataSource?.title ?? "" )
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Next", comment: ""),
            style: .plain,
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
                style: .plain,
                target: self,
                action: #selector(cancel)
            )
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white
        ]
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.options.clearSelectionOnAppearance {
            collectionView?.selectItem(at: nil, animated: true, scrollPosition: UICollectionViewScrollPosition())
        }
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func cancel() {
        progressHUD?.hide(animated: true)
        self.mediaExporter?.cancelDownload()
        delegate?.mediaSearchDidCancel?()
    }
    
    // MARK: - API
    
    func continueWithSelectedItem(_ sender: AnyObject?) {
        guard let indexPath = self.selectedIndexPath else {
            return
        }
        
        let mediaSearchResultObject = self.dataSourceAdapter.sections[ (indexPath as NSIndexPath).section ][ (indexPath as NSIndexPath).row ]
        
        if options.shouldSkipExportRendering {
            if let thumbnailImageURL = mediaSearchResultObject.thumbnailImageURL {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    if let previewImageData = try? Data(contentsOf: thumbnailImageURL as URL, options: []) {
                        mediaSearchResultObject.exportPreviewImage = UIImage(data: previewImageData)
                    }
                    DispatchQueue.main.async {
                        self?.delegate?.mediaSearchResultSelected( mediaSearchResultObject )
                    }
                }
            }
        } else {
            exportMedia(fromSearchResult: mediaSearchResultObject)
        }
    }
    
    func exportMedia(fromSearchResult mediaSearchResultObject: MediaSearchResult) {
        guard let view = Bundle.main.loadNibNamed("LoadingCancellableView", owner: self, options: nil)?.first as? LoadingCancellableView else {
            return
        }
        view.delegate = self
        
        MBProgressHUD.hide(for: self.view, animated: false)
        progressHUD = MBProgressHUD.showAdded(to: self.view.window!, animated: true)
        progressHUD?.mode = MBProgressHUDMode.customView
        progressHUD?.customView = view
        progressHUD?.isSquare = true
        progressHUD?.show(animated: true)
        
        self.mediaExporter?.cancelDownload()
        self.mediaExporter = nil
        
        let mediaExporter = MediaSearchExporter(mediaSearchResult: mediaSearchResultObject)
        mediaExporter.loadMedia() { [weak self] (previewImage, mediaURL, error) in
            dispatch_after(0.5) {
                guard let strongSelf = self , !mediaExporter.cancelled else {
                    return
                }
                strongSelf.progressHUD?.hide(animated: true)
                if let previewImage = previewImage, let mediaURL = mediaURL {
                    mediaSearchResultObject.exportPreviewImage = previewImage
                    mediaSearchResultObject.exportMediaURL = mediaURL as URL
                    strongSelf.delegate?.mediaSearchResultSelected( mediaSearchResultObject )
                } else {
                    strongSelf.progressHUD?.hide(animated: true)
                    strongSelf.showHud(renderingError: error)
                }
            }
        }
        self.mediaExporter = mediaExporter
    }
    
    fileprivate func showHud(renderingError error: NSError?) {
        if error?.code != NSURLErrorCancelled {
            MBProgressHUD.hide(for: view, animated: false)
            let errorTitle = NSLocalizedString("Error rendering media", comment: "")
            v_showErrorWithTitle(errorTitle, message: "")
        }
    }
    
    func selectCellAtSelectedIndexPath() {
        if let indexPath = self.selectedIndexPath {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
        }
    }
    
    func performSearch(searchTerm: String?, pageType: VPageType = .first) {
        if self.dataSourceAdapter.state != .loading {
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
            self.collectionView.reloadSections( IndexSet(integer: 0) )
            })
    }
    
    func updateViewWithResult( _ result: MediaSearchDataSourceAdapter.ChangeResult? ) {
        if let result = result , result.hasChanges {
            self.collectionView.performBatchUpdates({
                self.collectionView.applyDataSourceChanges( result )
                })
        }
        if result?.error != nil || (result?.hasChanges == false && (self.dataSourceAdapter.dataSource?.visibleItems.count ?? 0) == 0) {
            self.collectionView.reloadData()
        }
    }
    
    func clearSearch() {
        self.collectionView.performBatchUpdates({
            let result = self.dataSourceAdapter.clear()
            self.collectionView.applyDataSourceChanges( result )
            })
        
        self.selectedIndexPath = nil
        self.previewSection = nil
        self.collectionView.setContentOffset( CGPoint.zero, animated: false )
        self.updateLayout()
    }
    
    fileprivate func titleViewWithTitle( _ text: String ) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = UIFont.preferredFont( forTextStyle: UIFontTextStyle.headline )
        label.textColor = UIColor.white
        label.sizeToFit()
        return label
    }
    
    fileprivate func updateNavigationItemState() {
        self.navigationItem.rightBarButtonItem?.isEnabled = selectedIndexPath != nil
        self.navigationItem.rightBarButtonItem?.accessibilityIdentifier = AutomationId.MediaSearchNext.rawValue
    }
    
    /// Inserts a new section into the collection view that shows a fullsize preview video for the search result
    func showPreviewForResult( _ indexPath: IndexPath ) {
        var sectionInserted: Int?
        
        self.collectionView.performBatchUpdates({
            let result = self.dataSourceAdapter.addHighlightSection(forIndexPath: indexPath)
            sectionInserted = result.insertedSections?.integerGreaterThan(0)
            self.collectionView.applyDataSourceChanges( result )
            })
        
        if let sectionInserted = sectionInserted {
            let previewCellIndexPath = IndexPath(row: 0, section: sectionInserted)
            if let cell = self.collectionView.cellForItem( at: previewCellIndexPath ) {
                self.collectionView.sendSubview( toBack: cell )
            }
            self.selectedIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: sectionInserted - 1)
            self.previewSection = sectionInserted
            
            self.collectionView.scrollToItem(at: previewCellIndexPath, at: .centeredVertically, animated: true)
            self.updateLayout()
        }
        
        self.updateNavigationItemState()
    }
    
    /// Invalidates the layout through a batch update so layout changes are animated
    fileprivate func updateLayout() {
        self.collectionView.performBatchUpdates({
            self.collectionView.collectionViewLayout.invalidateLayout()
        })
    }
    
    /// Removes the section showing a search result preview at the specified index path
    func hidePreviewForResult(_ indexPath: IndexPath) {
        self.collectionView.performBatchUpdates({
            let result = self.dataSourceAdapter.removeHighlightSection()
            self.collectionView.applyDataSourceChanges(result)
        })
        
        self.selectedIndexPath = nil
        self.previewSection = nil
        
        self.collectionView.performBatchUpdates({
            self.collectionView.collectionViewLayout.invalidateLayout()
        })
        
        self.updateNavigationItemState()
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text , searchTerm.characters.count > 0 else {
            return
        }
        self.clearSearch()
        self.performSearch(searchTerm: searchTerm)
        searchBar.resignFirstResponder()
    }
    
    // MARK: - VPaginatedDataSourceDelegate
    
    func paginatedDataSource(_ paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: VDataSourceState, to newState: VDataSourceState) {
        if hasLoadedOnce {
            self.updateLayout()
        }
    }
    
    func paginatedDataSource(_ paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        // `MediaSearchDataSourceAdapter` handles errors in its own unique way
    }
    
    func paginatedDataSource(_ paginatedDataSource: PaginatedDataSource, didReceiveError error: Error) {
        // `MediaSearchDataSourceAdapter` handles errors in its own unique way
    }
}

/// Conveninece method to insert/delete sections during a batch update
private extension UICollectionView {
    
    /// Inserts or deletes sections according to the inserted and deleted sections indicated in the result
    ///
    /// - parameter result: A `MediaSearchDataSourceAdapter.ChangeResult` that contains info about which sections to insert or delete
    func applyDataSourceChanges( _ result: MediaSearchDataSourceAdapter.ChangeResult ) {
        
        if let insertedSections = result.insertedSections {
            self.insertSections( insertedSections as IndexSet )
        }
        if let deletedSections = result.deletedSections {
            self.deleteSections( deletedSections as IndexSet )
        }
    }
}
