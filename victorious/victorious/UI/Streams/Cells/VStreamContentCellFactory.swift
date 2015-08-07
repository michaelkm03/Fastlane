//
//  VStreamContentCellFactory.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class VStreamContentCellFactory: NSObject, VStreamCellFactory, VHasManagedDependencies {
    
    weak var delegate : VStreamContentCellFactoryDelegate? {
        didSet {
            marqueeCellFactory.marqueeController?.setSelectionDelegate(delegate)
            marqueeCellFactory.marqueeController?.setDataDelegate(delegate)
        }
    }
    
    private let marqueeCellFactory : VMarqueeCellFactory
    private let dependencyManager : VDependencyManager
    var defaultFactory : VStreamCellFactory?
    
    required init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        marqueeCellFactory = VMarqueeCellFactory(dependencyManager: dependencyManager)
    }
    
    func registerCellsWithCollectionView(collectionView: UICollectionView!) {
        defaultFactory?.registerCellsWithCollectionView(collectionView)
        marqueeCellFactory.registerCellsWithCollectionView(collectionView)
    }
    
    func collectionView(collectionView: UICollectionView!, cellForStreamItem streamItem: VStreamItem!, atIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        return factory(streamItem)?.collectionView(collectionView, cellForStreamItem: streamItem, atIndexPath: indexPath)
    }
    
    func sizeWithCollectionViewBounds(bounds: CGRect, ofCellForStreamItem streamItem: VStreamItem!) -> CGSize {
        if let factory = factory(streamItem) {
            return factory.sizeWithCollectionViewBounds(bounds, ofCellForStreamItem: streamItem)
        }
        return CGSizeZero
    }
    
    func minimumLineSpacing() -> CGFloat {
        return 1
    }
    
    func sectionInsets() -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func factory(streamItem: VStreamItem) -> VStreamCellFactory? {
        let itemType = streamItem.normalizedItemType()
        let subType = streamItem.normalizedItemSubType()
        
        switch itemType {
        case .Marquee:
            return marqueeCellFactory
        default:
            break
        }
        return defaultFactory
    }
}
