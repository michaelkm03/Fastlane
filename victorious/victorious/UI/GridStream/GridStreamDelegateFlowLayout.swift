//
//  HeaderContentStreamDelegateFlowLayout.swift
//  victorious
//
//  Created by Vincent Ho on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

protocol ConfigurableGridStreamCollectionView {
    func willDisplaySupplementaryView(footerView: VFooterActivityIndicatorView)
}

class GridStreamDelegateFlowLayout<HeaderType: ConfigurableGridStreamHeader>: NSObject, UICollectionViewDelegateFlowLayout {
    
    private var content: HeaderType.ContentType
    private var dependencyManager: VDependencyManager
    private var header: HeaderType?
    private var configuration: CollectionViewConfiguration
    
    var configurableViewController: ConfigurableGridStreamCollectionView?
    
    init(dependencyManager: VDependencyManager,
         header: HeaderType? = nil,
         content: HeaderType.ContentType,
         configuration: CollectionViewConfiguration) {
        
        self.dependencyManager = dependencyManager
        self.content = content
        self.header = header
        self.configuration = configuration
        super.init()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        guard let header = header else {
            return CGSizeZero
        }
        let size = header.sizeForHeader(
            dependencyManager,
            maxHeight: CGRectGetHeight(collectionView.bounds),
            content: content)
        return size
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        return flowLayout.v_cellSize(
            fittingWidth: collectionView.bounds.width,
            cellsPerRow: configuration.cellsPerRow
        )
    }
    
    func collectionView(collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        atIndexPath indexPath: NSIndexPath) {
        if let footerView = view as? VFooterActivityIndicatorView {
            configurableViewController?.willDisplaySupplementaryView(footerView)
        }
    }
}