//
//  GIFSearchViewController+Delegate.swift
//  victorious
//
//  Created by Patrick Lynch on 7/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

extension GIFSearchViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let section = self.searchDataSource.sections[ indexPath.section ]
        if collectionView.cellForItemAtIndexPath( indexPath ) is GIFSearchResultCell {
            if self.selectedIndexPath == indexPath {
                self.hideFullSize( forItemAtIndexPath: indexPath )
            }
            else {
                self.showFullSize( forItemAtIndexPath: indexPath )
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return collectionView.cellForItemAtIndexPath( indexPath ) is GIFSearchResultCell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let insets = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? UIEdgeInsets()
        let numRowsInSection = collectionView.numberOfItemsInSection(indexPath.section)
        let totalWidth = collectionView.bounds.width - insets.left - insets.right - kItemSpacing * CGFloat(numRowsInSection - 1)
        let totalHeight = collectionView.bounds.height - insets.top - insets.bottom
        let totalSize = CGSize(width: totalWidth, height: totalHeight)
        
        if self.searchDataSource.sections.count == 0 {
            return CGSize(width: totalSize.width, height: kNoContentCellHeight)
        }
        else {
            let section = self.searchDataSource.sections[ indexPath.section ]
            if section.count == 1 {
                return section.previewSectionCellSize(withinSize: totalSize)
            }
            else {
                let sizes = section.resultSectionDisplaySizes( withinSize: totalSize )
                return sizes[ indexPath.row ]
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let isFirstSection = section == 0
        return CGSize(width: collectionView.bounds.width, height: isFirstSection ? kHeaderViewHeight : 0.0 )
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if let previewSection = self.previewSection where previewSection == section {
            return UIEdgeInsets(top: kDefaultSectionMargin, left: kDefaultSectionMargin, bottom: kDefaultSectionMargin, right: kDefaultSectionMargin)
        }
        else {
            return UIEdgeInsets(top: kItemSpacing, left: kDefaultSectionMargin, bottom: 0, right: kDefaultSectionMargin)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let isLastSection = section == collectionView.numberOfSections() - 1
        return CGSize(width: collectionView.bounds.width, height: isLastSection ? kFooterViewHeight : 0.0 )
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.tintColor = self.dependencyManager?.colorForKey( VDependencyManagerLinkColorKey )
    }
}

// Provides some size calculation methods to be used when determine sizes for cells in a collection view
private extension GIFSearchDataSource.Section {
    
    func previewSectionCellSize( withinSize totalSize: CGSize ) -> CGSize {
        let gif = self.results[0]
        let maxHeight = totalSize.height - GIFSearchDataSource.Section.kMinMargin * 2.0
        return CGSize(width: totalSize.width, height: min(totalSize.width / gif.aspectRatio, maxHeight) )
    }
    
    func resultSectionDisplaySizes( withinSize totalSize: CGSize ) -> [CGSize] {
        assert( self.results.count == 2, "This method only calculates sizes for sections with exactly 2 results" )
        
        var output = [CGSize](count: self.results.count, repeatedValue: CGSize.zeroSize)
        
        let gifA = self.results[0]
        let gifB = self.results[1]
        
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
        let widthA = floor( totalSize.width * ratioA )
        output[0] = CGSize(width: widthA, height: widthA / gifA.aspectRatio )
        
        let ratioB = sizeB.width / (sizeA.width + sizeB.width)
        let widthB = floor( totalSize.width * ratioB )
        output[1] = CGSize(width: widthB, height: widthB / gifB.aspectRatio )
        
        return output
    }
}