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

private extension NSIndexPath {
    
    func asIndexSet() -> NSIndexSet {
        return NSIndexSet(index: self.section )
    }
}

class GIFSearchViewController: UIViewController, VMediaSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let searchDataSource = GIFSearchDataSource()
    
    static func viewControllerFromStoryboard() -> GIFSearchViewController {
        let bundle = UIStoryboard(name: "GIFSearch", bundle: nil)
        if let viewController = bundle.instantiateInitialViewController() as? GIFSearchViewController {
            return viewController
        }
        fatalError( "Could not load GIFSearchViewController from storyboard." )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        self.searchBar.textField?.textColor = UIColor.whiteColor()
        self.searchBar.textField?.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        
        self.collectionView.dataSource = self.searchDataSource
        self.collectionView.delegate = self
        self.searchBar.placeholder = NSLocalizedString( "Search", comment:"" )
        
        self.navigationItem.titleView = self.titleViewWithTitle( NSLocalizedString( "GIF", comment:"" ) )
        
        self.performSearch()
    }
    
    func showFullSize( forItemAtIndexPath indexPath: NSIndexPath ) {
        
        self.collectionView.performBatchUpdates({
            self.searchDataSource.addHighlightSection(forIndexPath: indexPath )
            self.collectionView.insertSections( indexPath.nextSectionIndexPath().asIndexSet() )
        }, completion: nil)
        
        self.collectionView.scrollToItemAtIndexPath( indexPath.nextSectionIndexPath(), atScrollPosition: .CenteredVertically, animated: true )
    }
    
    func hideFullSize( forItemAtIndexPath indexPath: NSIndexPath ) {
        self.collectionView.performBatchUpdates({
            //let indexPathRemoved = self.searchDataSource.removeHighlightSection(forIndexPath: indexPath )
            //self.collectionView.deleteSections( indexPathRemoved.asIndexSet() )
        }, completion: nil )
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
            self.self.collectionView.reloadData()
        }
    }
    
    private func clearSearch() {
        self.searchDataSource.clear()
        self.collectionView.reloadData()
    }
    
    // MARK: - VMediaSource
    
    var handler: VMediaSelectionHandler?
}

extension GIFSearchViewController : UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if count( searchText ) == 0 {
            self.clearSearch()
        }
        else {
            self.performSearch( searchText )
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
