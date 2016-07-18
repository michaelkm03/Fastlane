//
//  VContentOnlyCellFactory.swift
//  victorious
//
//  Created by Jarod Long on 4/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A cell factory for `VContentOnlyCell`s.
class VContentOnlyCellFactory: NSObject {
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        super.init()
    }
    
    // MARK: - Dependency manager
    
    private let dependencyManager: VDependencyManager
    
    
    private var registeredReuseIdentifiers = Set<String>()
    
    func collectionView(collectionView: UICollectionView, cellForContent content: ContentModel, atIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseIdentifier = ContentPreviewView.defaultReuseIdentifier
        
        if !registeredReuseIdentifiers.contains(reuseIdentifier) {
            collectionView.registerClass(VContentOnlyCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            registeredReuseIdentifiers.insert(reuseIdentifier)
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! VContentOnlyCell
        cell.dependencyManager = dependencyManager
        cell.content = content
        return cell
    }    
}
