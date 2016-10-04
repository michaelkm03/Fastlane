//
//  MediaSearchViewController+Layout.swift
//  victorious
//
//  Created by Patrick Lynch on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

// A type that provides static constants used for metrics in layout calculations
private struct MediaSearchLayout {
    static let headerViewHeight: CGFloat      = 50.0
    static let footerViewHeight: CGFloat      = 50.0
    static let defaultSectionMargin: CGFloat  = 10.0
    static let noContentCellHeight: CGFloat   = 80.0
    static let itemSpacing: CGFloat           = 2.0
}

extension MediaSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insets = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? UIEdgeInsets()
        let numRowsInSection = collectionView.numberOfItems(inSection: (indexPath as NSIndexPath).section)
        let totalWidth = collectionView.bounds.width - insets.left - insets.right - MediaSearchLayout.itemSpacing * CGFloat(numRowsInSection - 1)
        let totalHeight = collectionView.bounds.height - insets.top - insets.bottom
        let totalSize = CGSize(width: totalWidth, height: totalHeight)
        
        if self.dataSourceAdapter.sections.count == 0 {
            return CGSize(width: totalSize.width, height: MediaSearchLayout.noContentCellHeight)
        }
        else {
            let section = self.dataSourceAdapter.sections[ (indexPath as NSIndexPath).section ]
            if section.count == 1 {
                return section.previewSectionCellSize(withinSize: totalSize)
            }
            else {
                let sizes = section.resultSectionDisplaySizes( withinSize: totalSize )
                return sizes[ (indexPath as NSIndexPath).row ]
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if options.showAttribution {
            let headerHeight = self.shouldShowHeader(section) ? MediaSearchLayout.headerViewHeight : 0.0
            return CGSize(width: collectionView.bounds.width, height: headerHeight )
            
        } else {
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let previewSection = self.previewSection , previewSection == section {
            return UIEdgeInsets(
                top: MediaSearchLayout.defaultSectionMargin,
                left: MediaSearchLayout.defaultSectionMargin,
                bottom: MediaSearchLayout.defaultSectionMargin,
                right: MediaSearchLayout.defaultSectionMargin)
        }
        else {
            return UIEdgeInsets(
                top: MediaSearchLayout.itemSpacing,
                left: MediaSearchLayout.defaultSectionMargin,
                bottom: self.shouldShowFooter(section) ? 0.0 : self.isLastSection(section) ? MediaSearchLayout.defaultSectionMargin : 0.0,
                right: MediaSearchLayout.defaultSectionMargin)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let footerHeight = self.shouldShowFooter(section) ? MediaSearchLayout.footerViewHeight : 0.0
        return CGSize(width: collectionView.bounds.width, height: footerHeight )
    }
    
    // MARK: - Private
    
    fileprivate func isLastSection( _ section: Int ) -> Bool {
        let numSections = collectionView.numberOfSections
        return section == numSections - 1
    }
    
    fileprivate func shouldShowFooter( _ section: Int ) -> Bool {
        let numSections = collectionView.numberOfSections
        let output = numSections > 1 && self.isLastSection(section)
        return output
    }
    
    fileprivate func shouldShowHeader( _ section: Int ) -> Bool {
        return section == 0
    }
}

// Provides some size calculation methods to be used when determine sizes for cells in a collection view
private extension MediaSearchDataSourceAdapter.Section {
    
    func previewSectionCellSize( withinSize totalSize: CGSize ) -> CGSize {
        let gif = self.results[0]
        let maxHeight = totalSize.height - MediaSearchDataSourceAdapter.Section.minCollectionContainerMargin * 2.0
        return CGSize(width: totalSize.width, height: min(totalSize.width / gif.aspectRatio, maxHeight) )
    }
    
    func resultSectionDisplaySizes( withinSize totalSize: CGSize ) -> [CGSize] {
        assert( self.results.count == 2, "This method only calculates sizes for sections with exactly 2 results" )
        
        var output = [CGSize](repeating: CGSize.zero, count: self.results.count)
        
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
