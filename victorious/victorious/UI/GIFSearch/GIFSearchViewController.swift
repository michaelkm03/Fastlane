//
//  GIFSearchViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

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

class GIFSearchViewController: UIViewController, VMediaSource {
    
    enum Action: Selector {
        case Next = "onNext:"
    }
    
    let kHeaderViewHeight: CGFloat = 50.0
    let kDefaultSectionMargin: CGFloat = 10.0
    let kNoContentCellHeight: CGFloat = 150.0

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedIndexPath: NSIndexPath?
    let searchDataSource = GIFSearchDataSource()
    private(set) var dependencyManager: VDependencyManager?
    private lazy var mediaHelper = GIFSearchMediaHelper()
    
    // VMediaSource
    var handler: VMediaSelectionHandler?
    
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
        
        let nextTitle = NSLocalizedString( "Next", comment: "" )
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: nextTitle, style: .Plain, target: self, action: Action.Next.rawValue )
        
        self.performSearch()
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
                    self.handler?( previewImage, mediaURL )
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
    
    private func performSearch( _ searchText: String = "" ) {
        self.searchDataSource.performSearch( searchText ) {
            self.collectionView.setContentOffset( CGPoint.zeroPoint, animated: true )
            self.collectionView.reloadData()
        }
    }
    
    private func clearSearch() {
        self.searchDataSource.clear()
        self.collectionView.reloadData()
    }
}

extension GIFSearchViewController : UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.clearSearch()
        self.performSearch( searchText )
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
