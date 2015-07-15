//
//  GIFSearchViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// Delegate that handles events that originate from within a `GIFSearchViewController`
@objc protocol GIFSearchViewControllerDelegate {
    
    /// The user selected a GIF image and wants to proceed with it in a creation flow.
    ///
    /// :param: `previewImage` A small, stille image that is loaded into memory and ready to display
    /// :param: `capturedMediaURL` The file URL of the GIF's mp4 video asset downloaded to a file temporary location on the device
    func GIFSelectedWithPreviewImage( previewImage: UIImage, capturedMediaURL: NSURL )
}

/// View controller that allows users to search for GIF files using the Giphy API
/// as part of a content creation flow.
class GIFSearchViewController: UIViewController {
    
    /// Enum of selector strings used in this class
    private enum Action: Selector {
        case Next = "onNextSelected:"
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedIndexPath: NSIndexPath?
    var previewSection: Int?
    private var isScrollViewDecelerating = false
    private(set) var dependencyManager: VDependencyManager?
    
    let scrollPaginator = VScrollPaginator()
    let searchDataSource = GIFSearchDataSource()
    private lazy var mediaHelper = GIFSearchMediaHelper()
    
    var delegate: GIFSearchViewControllerDelegate?
    
    static func gifSearchWithDependencyManager( depndencyManager: VDependencyManager ) -> GIFSearchViewController {
        let bundle = UIStoryboard(name: "GIFSearch", bundle: nil)
        if let viewController = bundle.instantiateInitialViewController() as? GIFSearchViewController {
            viewController.dependencyManager = depndencyManager
            return viewController
        }
        fatalError( "Could not load GIFSearchViewController from storyboard." )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollPaginator.delegate = self
        
        self.searchBar.delegate = self
        if let searchTextField = self.searchBar.v_textField {
            searchTextField.font = self.dependencyManager?.fontForKey(VDependencyManagerHeading3FontKey)
            searchTextField.textColor = UIColor.whiteColor()
            searchTextField.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        }
        
        self.collectionView.dataSource = self.searchDataSource
        self.collectionView.delegate = self
        self.searchBar.placeholder = NSLocalizedString( "Search", comment:"" )
        
        self.navigationItem.titleView = self.titleViewWithTitle( NSLocalizedString( "GIF", comment:"" ) )
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Next", comment: ""),
            style: .Plain,
            target: self,
            action: Action.Next.rawValue )
        
        self.performSearch()
    }
    
    func onNextSelected( sender: AnyObject? ) {
        if let indexPath = self.selectedIndexPath {
            
            let selectedGIF = self.searchDataSource.sections[ indexPath.section ][ indexPath.row ]
            
            var progressHUD = MBProgressHUD.showHUDAddedTo( self.view, animated: true )
            progressHUD.mode = .Indeterminate
            progressHUD.dimBackground = true
            progressHUD.show(true)
            
            self.mediaHelper.loadMedia( selectedGIF ) { (previewImage, mediaURL, error) in
                
                if let previewImage = previewImage, let mediaURL = mediaURL {
                    self.delegate?.GIFSelectedWithPreviewImage( previewImage, capturedMediaURL: mediaURL )
                }
                else {
                    println( "Error: \(error)" )
                }
                
                progressHUD.hide(true)
            }
        }
    }
    
    private func performSearch( _ searchText: String = "", pageType: VPageType = .First ) {
        self.searchDataSource.performSearch( searchText, pageType: pageType ) {
            self.collectionView.reloadData()
        }
    }
    
    private func clearSearch() {
        self.searchDataSource.clear()
        self.collectionView.reloadData()
        self.collectionView.setContentOffset( CGPoint.zeroPoint, animated: false )
    }
    
    private func titleViewWithTitle( text: String ) -> UIView {
        var label = UILabel()
        label.text = text
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        return label
    }
}

extension GIFSearchViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.clearSearch()
        self.performSearch( searchBar.text )
        searchBar.resignFirstResponder()
    }
}

extension GIFSearchViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        self.scrollPaginator.scrollViewDidScroll( scrollView )
        
        if !self.isScrollViewDecelerating && self.searchBar.isFirstResponder() {
            self.searchBar.resignFirstResponder()
        }
        
        self.isScrollViewDecelerating = true
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.isScrollViewDecelerating = false
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.isScrollViewDecelerating = false
    }
}

extension GIFSearchViewController : VScrollPaginatorDelegate {
    
    func shouldLoadNextPage() {
        if let searchText = self.searchBar.text {
            self.performSearch(searchText, pageType: .Next)
        }
    }
}

private extension UISearchBar {
    
    /// Finds the `UITextField` subview into which users type their search string
    var v_textField: UITextField? {
        return self.v_findSubview({ $0 is UITextField }) as? UITextField
    }
}