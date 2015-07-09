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

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    private let _searchDataSource = GIFSearchDataSource()
    private var _sizes = [CGSize]()
    
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
        
        self.collectionView.dataSource = _searchDataSource
        self.collectionView.delegate = self
        self.searchBar.placeholder = NSLocalizedString( "Search", comment:"" )
        
        var label = UILabel()
        label.text = NSLocalizedString( "GIF", comment:"" )
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        self.navigationItem.titleView = label
        
        self.performSearch()
    }
    
    private func performSearch( _ searchText: String = "" ) {
        _searchDataSource.performSearch( searchText ) {
            self.updateSizes( self._searchDataSource.results )
            self.self.collectionView.reloadData()
        }
    }
    
    private func clearSearch() {
        _searchDataSource.clear()
        self.collectionView.reloadData()
    }
    
    private func updateSizes( results: [GIFSearchResult] ) {
        
        let totalWidth = CGRectGetWidth(self.collectionView.bounds)
        _sizes = [CGSize]( count: results.count, repeatedValue: CGSizeZero )
        for var i = 0; i < results.count-1; i+=2 {
            let gifA = results[i]
            let gifB = results[i+1]
            
            var sizeA = gifA.assetSize
            var sizeB = gifB.assetSize
            
            let hRatioA = sizeA.height / sizeB.height
            let hRatioB = sizeB.height / sizeA.height
            
            if hRatioA >= 1.0 {
                sizeB.width /= hRatioB
                sizeB.height /= hRatioB
            }
            else if hRatioB >= 1.0 {
                sizeA.width /= hRatioA
                sizeA.height /= hRatioA
            }
            
            let ratioA = sizeA.width / (sizeA.width + sizeB.width)
            let widthA = floor( totalWidth * ratioA )
            _sizes[i] = CGSize(width: widthA, height: widthA / gifA.aspectRatio )
            
            let ratioB = sizeB.width / (sizeA.width + sizeB.width)
            let widthB = floor( totalWidth * ratioB )
            _sizes[i+1] = CGSize(width: widthB, height: widthB / gifB.aspectRatio )
        }
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
}
    
extension GIFSearchViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return _sizes[ indexPath.row ]
    }
}
