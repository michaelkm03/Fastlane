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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let insets = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? UIEdgeInsets()
        let numRowsInSection = collectionView.numberOfItemsInSection(indexPath.section)
        let totalWidth = collectionView.bounds.width - insets.left - insets.right - MediaSearchLayout.itemSpacing * CGFloat(numRowsInSection - 1)
        let totalHeight = collectionView.bounds.height - insets.top - insets.bottom
        let totalSize = CGSize(width: totalWidth, height: totalHeight)
        
        if self.dataSourceAdapter.sections.count == 0 {
            return CGSize(width: totalSize.width, height: MediaSearchLayout.noContentCellHeight)
        }
        else {
            let section = self.dataSourceAdapter.sections[ indexPath.section ]
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
       
        if options.showAttribution {
            let headerHeight = self.shouldShowHeader(section) ? MediaSearchLayout.headerViewHeight : 0.0
            return CGSize(width: collectionView.bounds.width, height: headerHeight )
        } else {
            return CGSize.zero
        }
    }
    
    func collectionView(collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        guard
            let attributionHeader = view as? AttributionHeaderView,
            let attributionImage = options.attributionImage
        else {
            return
        }
        attributionHeader.imageView.image = attributionImage
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if let previewSection = self.previewSection where previewSection == section {
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let footerHeight = self.shouldShowFooter(section) ? MediaSearchLayout.footerViewHeight : 0.0
        return CGSize(width: collectionView.bounds.width, height: footerHeight )
    }
    
    // MARK: - Private
    
    private func isLastSection( section: Int ) -> Bool {
        let numSections = collectionView.numberOfSections()
        return section == numSections - 1
    }
    
    private func shouldShowFooter( section: Int ) -> Bool {
        let numSections = collectionView.numberOfSections()
        let output = numSections > 1 && self.isLastSection(section)
        return output
    }
    
    private func shouldShowHeader( section: Int ) -> Bool {
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
        
        var output = [CGSize](count: self.results.count, repeatedValue: CGSize.zero)
        
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
