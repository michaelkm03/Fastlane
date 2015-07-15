//
//  GIFSearchViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class GIFSearchViewController: UIViewController {
    
    enum Action: Selector {
        case Next = "onNext:"
    }
    
    let kHeaderViewHeight: CGFloat      = 50.0
    let kFooterViewHeight: CGFloat      = 50.0
    let kDefaultSectionMargin: CGFloat  = 10.0
    let kNoContentCellHeight: CGFloat   = 80.0
    let kItemSpacing: CGFloat           = 2.0

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedIndexPath: NSIndexPath?
    var previewSection: Int?
    private var isScrollViewDecelerating = false
    private(set) var dependencyManager: VDependencyManager?
    
    let scrollPaginator = VScrollPaginator()
    let searchDataSource = GIFSearchDataSource()
    private lazy var mediaHelper = GIFSearchMediaHelper()
    
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
        if let searchTextField = self.searchBar.textField {
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
    
    func performSearch( _ searchText: String = "", pageType: VPageType = .First ) {
        self.searchDataSource.performSearch( searchText, pageType: pageType ) {
            self.collectionView.reloadData()
        }
    }
    
    func clearSearch() {
        self.searchDataSource.clear()
        self.collectionView.reloadData()
        self.collectionView.setContentOffset( CGPoint.zeroPoint, animated: false )
    }
    
    func onNext( sender: AnyObject? ) {
        if let indexPath = self.selectedIndexPath {
            
            let selectedGIF = self.searchDataSource.sections[ indexPath.section ][ indexPath.row ]
            
            var progressHUD = MBProgressHUD.showHUDAddedTo( self.view, animated: true )
            progressHUD.mode = .Indeterminate
            progressHUD.dimBackground = true
            progressHUD.show(true)
            
            self.mediaHelper.loadMedia( selectedGIF ) { (previewImage, mediaUrl, error) in
                
                if let previewImage = previewImage, let mediaURL = mediaUrl {
                    //self.handler?( previewImage, mediaURL )
                }
                else {
                    println( "Error: \(error)" )
                }
                
                progressHUD.hide(true)
            }
        }
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

private extension UIView {
    
    /// UIView extension
    /// parameter `pattern`: Closure to call to determine if view is the one sought
    /// returns: A view that passes the test or nil
    func findSubview( pattern: (UIView)->(Bool) ) -> UIView? {
        for subview in self.subviews as! [UIView] {
            if pattern( subview ) {
                return subview
            }
            else if let result = subview.findSubview( pattern ) {
                return result
            }
        }
        return nil
    }
}

private extension UISearchBar {
    
    /// Returns the text field into which users type their search string
    var textField: UITextField? {
        return self.findSubview({ $0 is UITextField }) as? UITextField
    }
}