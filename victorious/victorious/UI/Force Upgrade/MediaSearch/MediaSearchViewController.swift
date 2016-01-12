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
    
    /// The user selected a GIF image and wants to proceed with it in a creation flow.
    func mediaSearchResultSelected( selectedMediaSearchResult: MediaSearchResult )
}

/// View controller that allows users to search for GIF files using the Giphy API
/// as part of a content creation flow.
class MediaSearchViewController: UIViewController, VScrollPaginatorDelegate, UISearchBarDelegate {
    
    /// Enum of selector strings used in this class
    private enum Action: Selector {
        case ExportSelectedItem = "exportSelectedItem:"
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedIndexPath: NSIndexPath?
    var previewSection: Int?
    var isScrollViewDecelerating = false
    private(set) var dependencyManager: VDependencyManager?
    
    let scrollPaginator = VScrollPaginator()
	let dataSourceController = MediaSearchDataSourceController()
    private lazy var mediaExporter = MediaSearchExporter()
    
	weak var delegate: MediaSearchViewControllerDelegate?
	
	class func mediaSearchViewController( dataSource dataSource: MediaSearchDataSource, depndencyManager: VDependencyManager ) -> MediaSearchViewController {
        let bundle = UIStoryboard(name: "MediaSearch", bundle: nil)
        if let viewController = bundle.instantiateInitialViewController() as? MediaSearchViewController {
            viewController.dependencyManager = depndencyManager
			viewController.dataSourceController.dataSource = dataSource
            return viewController
        }
        fatalError( "Could not load MediaSearchViewController from storyboard." )
    }
    
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
        
        self.collectionView.dataSource = self.dataSourceController
        self.collectionView.delegate = self
        self.searchBar.placeholder = NSLocalizedString( "Search", comment:"" )
        
        self.navigationItem.titleView = self.titleViewWithTitle( NSLocalizedString( "GIF Search", comment:"" ) )
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Next", comment: ""),
            style: .Plain,
            target: self,
            action: Action.ExportSelectedItem.rawValue )
		
		// Load with no search term for default results (determined by data sources)
		self.performSearch(searchTerm: nil)
		
        self.updateNavigationItemState()
    }
    
    func exportSelectedItem( sender: AnyObject? ) {
        guard let indexPath = self.selectedIndexPath else {
			return
		}
		
		let gifSearchResulObject = self.dataSourceController.sections[ indexPath.section ][ indexPath.row ]
		
		let progressHUD = MBProgressHUD.showHUDAddedTo( self.view.window, animated: true )
		progressHUD.mode = .Indeterminate
		progressHUD.dimBackground = true
		progressHUD.show(true)
		
		self.mediaExporter.loadMedia( gifSearchResulObject ) { (previewImage, mediaURL, error) in
			
			if let previewImage = previewImage, let mediaURL = mediaURL {
				gifSearchResulObject.exportPreviewImage = previewImage
				gifSearchResulObject.exportMediaURL = mediaURL
				self.delegate?.mediaSearchResultSelected( gifSearchResulObject )
				
			} else {
				let progressHUD = MBProgressHUD.showHUDAddedTo( self.view, animated: true )
				progressHUD.mode = .Text
				progressHUD.labelText = NSLocalizedString( "Error rendering GIF", comment:"" )
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
        if self.dataSourceController.state != .Loading {
			self.dataSourceController.performSearch( searchTerm: searchTerm, pageType: pageType ) { result in
                self.updateViewWithResult( result )
            }
        }
    }
    
    func updateViewWithResult( result: MediaSearchDataSourceController.ChangeResult? ) {
        if let result = result where result.hasChanges {
            self.collectionView.performBatchUpdates({
                self.collectionView.applyDataSourceChanges( result )
            }, completion: nil)
        }
        if result?.error != nil || (result?.hasChanges == false && self.dataSourceController.sections.count == 0) {
            self.collectionView.reloadData()
        }
    }
    
    func clearSearch() {
        self.collectionView.performBatchUpdates({
            let result = self.dataSourceController.clear()
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
    
    /// Inserts a new section into the collection view that shows a fullsize preview video for the GIF search result
    func showPreviewForResult( indexPath: NSIndexPath ) {
        var sectionInserted: Int?
        
        self.collectionView.performBatchUpdates({
            let result = self.dataSourceController.addHighlightSection(forIndexPath: indexPath)
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
    
    /// Removes the section showing a GIF search result preview at the specified index path
    func hidePreviewForResult( indexPath: NSIndexPath ) {
        self.collectionView.performBatchUpdates({
            let result = self.dataSourceController.removeHighlightSection()
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
		self.performSearch(searchTerm: searchTerm)
		self.clearSearch()
		searchBar.resignFirstResponder()
	}
}

/// Conveninece method to insert/delete sections during a batch update
private extension UICollectionView {
    
    /// Inserts or deletes sections according to the inserted and deleted sections indicated in the result
    ///
    /// - parameter result: A `MediaSearchDataSourceController.ChangeResult` that contains info about which sections to insert or delete
    func applyDataSourceChanges( result: MediaSearchDataSourceController.ChangeResult ) {
        
        if let insertedSections = result.insertedSections {
            self.insertSections( insertedSections )
        }
        if let deletedSections = result.deletedSections {
            self.deleteSections( deletedSections )
        }
    }
}
