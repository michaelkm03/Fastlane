//
//  VStreamContentCellFactory.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

//2.0 Improvement: Transform this into a protocol extension.

/// A cell factory for representing shelved streams across the app. Treat this as an
/// abstract base class and only use concrete subclasses to utilize this class' functionality.
/// In Swift 2.0 this class should be transformed into a protocol extension.
class VStreamContentCellFactory: NSObject, VHasManagedDependencies {
    
    /// The object that should recieve messages about marquee data and selection updates.
    weak var delegate: VStreamContentCellFactoryDelegate? {
        didSet {
            marqueeCellFactory.marqueeController?.setSelectionDelegate(delegate)
            marqueeCellFactory.marqueeController?.setDataDelegate(delegate)
        }
    }
    
    /// The cell factory that will provide marquee cells
    private let marqueeCellFactory: VMarqueeCellFactory
    
    /// The dependency manager used to style all cells from this factory
    private let dependencyManager: VDependencyManager
    
    /// Nil by default, overridden by subclasses to return a factory that provides non-shelf cells
    func defaultFactory() -> VStreamCellFactory? {
        return nil
    }

    required init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        marqueeCellFactory = VMarqueeCellFactory(dependencyManager: dependencyManager)
    }
    
    private func factoryForStreamItem(streamItem: VStreamItem) -> VStreamCellFactory? {
        if let itemType = streamItem.itemType {
            if itemType == VStreamItemTypeMarquee {
                return marqueeCellFactory
            }
        }
        return defaultFactory()
    }
}

extension VStreamContentCellFactory: VStreamCellFactory {
    
    func registerCellsWithCollectionView(collectionView: UICollectionView) {
        defaultFactory()?.registerCellsWithCollectionView(collectionView)
        marqueeCellFactory.registerCellsWithCollectionView(collectionView)
    }
    
    func collectionView(collectionView: UICollectionView, cellForStreamItem streamItem: VStreamItem, atIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let factory = factoryForStreamItem(streamItem) {
            return factory.collectionView(collectionView, cellForStreamItem: streamItem, atIndexPath: indexPath)
        }
        assertionFailure("A cell was requested from a content cell factory with a nil default factory.")
        return UICollectionViewCell.new()
    }
    
    func sizeWithCollectionViewBounds(bounds: CGRect, ofCellForStreamItem streamItem: VStreamItem) -> CGSize {
        if let factory = factoryForStreamItem(streamItem) {
            return factory.sizeWithCollectionViewBounds(bounds, ofCellForStreamItem: streamItem)
        }
        return CGSize.zeroSize
    }
    
    func minimumLineSpacing() -> CGFloat {
        return 1
    }
    
    func sectionInsets() -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
}
