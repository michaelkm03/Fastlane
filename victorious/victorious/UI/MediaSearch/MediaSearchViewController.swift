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
@objc protocol MediaSearchViewControllerDelegate {
    
    /// The user selected a search result and wants to proceed with it in a creation flow.
    func mediaSearchResultSelected( selectedMediaSearchResult: MediaSearchResult )
}

class MediaSearchOptions: NSObject {
    var showPreview: Bool = false
    var showAttribution: Bool = false
    var clearSelectionOnAppearance: Bool = false
    
    static var defaultOptions: MediaSearchOptions {
        return MediaSearchOptions()
    }
}

/// View controller that allows users to search for media files as part of a content creation flow.
class MediaSearchViewController: UIViewController, VScrollPaginatorDelegate, UISearchBarDelegate, VPaginatedDataSourceDelegate {
    
    /// Enum of selector strings used in this class
    private enum Action: Selector {
        case ExportSelectedItem = "exportSelectedItem:"
    }

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
    
    let scrollPaginator = VScrollPaginator()
	let dataSourceAdapter = MediaSearchDataSourceAdapter()
    private lazy var mediaExporter = MediaSearchExporter()
    
	weak var delegate: MediaSearchViewControllerDelegate?
	
	class func mediaSearchViewController( dataSource dataSource: MediaSearchDataSource, depndencyManager: VDependencyManager ) -> MediaSearchViewController {
        let bundle = UIStoryboard(name: "MediaSearch", bundle: nil)
        if let viewController = bundle.instantiateInitialViewController() as? MediaSearchViewController {
            viewController.dependencyManager = depndencyManager
			viewController.dataSourceAdapter.dataSource = dataSource
            dataSource.delegate = viewController
            return viewController
        }
        fatalError( "Could not load MediaSearchViewController from storyboard." )
    }
    
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.accessibilityIdentifier = AutomationId.MediaSearchCollection.rawValue
        
        self.scrollPaginator.delegate = self
        
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
            action: Action.ExportSelectedItem.rawValue )
		
		// Load with no search term for default results (determined by data sources)
		self.performSearch(searchTerm: nil)
		
        self.updateNavigationItemState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.options.clearSelectionOnAppearance {
            collectionView?.selectItemAtIndexPath(nil, animated: true, scrollPosition: .None)
        }
    }
    
    //MARK: - API
    
    func exportSelectedItem( sender: AnyObject? ) {
        guard let indexPath = self.selectedIndexPath else {
			return
		}
		
		let mediaSearchResultObject = self.dataSourceAdapter.sections[ indexPath.section ][ indexPath.row ]
		
		let progressHUD = MBProgressHUD.showHUDAddedTo( self.view.window, animated: true )
		progressHUD.mode = .Indeterminate
		progressHUD.dimBackground = true
		progressHUD.show(true)
		
		self.mediaExporter.loadMedia( mediaSearchResultObject ) { (previewImage, mediaURL, error) in
			
			if let previewImage = previewImage, let mediaURL = mediaURL {
				mediaSearchResultObject.exportPreviewImage = previewImage
				mediaSearchResultObject.exportMediaURL = mediaURL
				self.delegate?.mediaSearchResultSelected( mediaSearchResultObject )
				
			} else {
				let progressHUD = MBProgressHUD.showHUDAddedTo( self.view, animated: true )
				progressHUD.mode = .Text
				progressHUD.labelText = NSLocalizedString( "Error rendering Media", comment:"" )
				progressHUD.hide(true, afterDelay: 3.0)
			}
			
			progressHUD.hide(true)
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
        }, completion:nil )
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
        }, completion:nil )
        
        self.updateNavigationItemState()
	}
	
	// MARK: - UISearchBarDelegate
	
	func shouldLoadNextPage() {
		// No need to pass in a search term, the data sources know how to discern based
		// on the search term of the previous page.
		self.performSearch(searchTerm: nil, pageType: .Next)
	}
	
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
