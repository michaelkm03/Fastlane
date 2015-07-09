//
//  GIFSearchViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

private extension GIFSearchResult {
    var aspectRatio: CGFloat {
        return CGFloat(self.width.integerValue) / CGFloat(self.height.integerValue)
    }
    
    var assetSize: CGSize {
        return CGSize(width: CGFloat(self.width.integerValue), height: CGFloat(self.height.integerValue) )
    }
}

private extension UIView {
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
    
    var textField: UITextField? {
        return self.findSubview({ $0 is UITextField }) as? UITextField
    }
}

class GIFSearchViewController: UIViewController, UICollectionViewDelegateFlowLayout, VCaptureContainedViewController, VMediaSource {

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
        
        self.searchBar.textField?.textColor = UIColor.whiteColor()
        self.searchBar.textField?.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        
        self.collectionView.dataSource = _searchDataSource
        self.collectionView.delegate = self
        _searchDataSource.reload() {
            self.updateSizes( self._searchDataSource.results )
            self.collectionView.reloadData()
        }
    }
    
    func updateSizes( results: [GIFSearchResult] ) {
        
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
    
    // MARK: - VCaptureContainerViewController
    
    var handler: VMediaSelectionHandler?
    
    // MARK: - VCaptureContainerViewController
    
    func titleView() -> UIView? {
        var label = UILabel()
        label.text = "GIF"
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        return label
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return _sizes[ indexPath.row ]
    }
}
