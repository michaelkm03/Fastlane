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
    
    fileprivate let dependencyManager: VDependencyManager
    
    
    fileprivate var registeredReuseIdentifiers = Set<String>()
    
    func collectionView(_ collectionView: UICollectionView, cellForContent content: Content, atIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = ContentPreviewView.defaultReuseIdentifier
        
        if !registeredReuseIdentifiers.contains(reuseIdentifier) {
            collectionView.register(VContentOnlyCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            registeredReuseIdentifiers.insert(reuseIdentifier)
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VContentOnlyCell
        cell.dependencyManager = dependencyManager
        cell.content = content
        return cell
    }    
}
