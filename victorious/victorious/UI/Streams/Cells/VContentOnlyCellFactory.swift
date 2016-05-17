//
//  VContentOnlyCellFactory.swift
//  victorious
//
//  Created by Jarod Long on 4/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A cell factory for `VContentOnlyCell`s.
class VContentOnlyCellFactory: NSObject, VStreamCellFactory {
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        super.init()
    }
    
    // MARK: - Dependency manager
    
    private let dependencyManager: VDependencyManager
    
    // MARK: - VStreamCellFactory
    
    private var registeredReuseIdentifiers = Set<String>()
    
    func registerCellsWithCollectionView(collectionView: UICollectionView) {
        // Cells are registered dynamically when dequeuing based on their stream item type.
    }
    
    func collectionView(collectionView: UICollectionView, cellForStreamItem streamItem: VStreamItem, atIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseIdentifier = VSequencePreviewView.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager)
        
        if !registeredReuseIdentifiers.contains(reuseIdentifier) {
            collectionView.registerClass(VContentOnlyCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            registeredReuseIdentifiers.insert(reuseIdentifier)
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! VContentOnlyCell
        cell.dependencyManager = dependencyManager
        cell.setStreamItem(streamItem)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, cellForViewedContent viewedContent: VViewedContent, atIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseIdentifier = ContentPreviewView.reuseIdentifier()
        
        if !registeredReuseIdentifiers.contains(reuseIdentifier) {
            collectionView.registerClass(VContentOnlyCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            registeredReuseIdentifiers.insert(reuseIdentifier)
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! VContentOnlyCell
        cell.dependencyManager = dependencyManager
        cell.setViewedContent(viewedContent)
        return cell
    }
    
    func sizeWithCollectionViewBounds(bounds: CGRect, ofCellForStreamItem streamItem: VStreamItem) -> CGSize {
        return CGSizeZero
    }
    
    func minimumLineSpacing() -> CGFloat {
        return 0.0
    }
    
    func sectionInsets() -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
}
