//
//  GIFSearchViewController+Layout.swift
//  victorious
//
//  Created by Patrick Lynch on 7/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

private let kHeaderHeight: CGFloat = 50.0

extension GIFSearchViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath( indexPath ) as? GIFSearchCell {
            let section = self.searchDataSource.sections[ indexPath.section ]
            
            if section.isHighlighted {
            }
            else {
                cell.focused = !cell.focused
                if cell.focused {
                    self.addHighlightedSection( forItemAtIndexPath: indexPath )
                }
                else {
                    self.removeHighlightedSection( forItemAtIndexPath: indexPath )
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let insets = (self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? UIEdgeInsets()
        let totalWidth = self.collectionView.bounds.width - insets.left - insets.right
        let section = self.searchDataSource.sections[ indexPath.section ]
        if section.count == 1 {
            return CGSize(width: totalWidth, height: 300.0)
        }
        else {
            let displaySizes = section.displaySizes( withinWidth: totalWidth )
            return displaySizes[ indexPath.row ]
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: section == 0 ? kHeaderHeight : 0.0 )
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let isLast = section == self.searchDataSource.sections.count-1
        return UIEdgeInsets(top: 0.0, left: 10.0, bottom: isLast ? 10.0 : 0.0, right: 10.0)
    }
}

private extension GIFSearchDataSource.Section {
    
    func displaySizes( withinWidth totalWidth: CGFloat ) -> [CGSize] {
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
        let widthA = floor( totalWidth * ratioA )
        output[0] = CGSize(width: widthA, height: widthA / gifA.aspectRatio )
        
        let ratioB = sizeB.width / (sizeA.width + sizeB.width)
        let widthB = floor( totalWidth * ratioB )
        output[1] = CGSize(width: widthB, height: widthB / gifB.aspectRatio )
        
        return output
    }
}