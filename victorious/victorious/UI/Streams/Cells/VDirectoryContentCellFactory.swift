//
//  VDirectoryContentCellFactory.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/**
    A cell factory that prepares and provides directory cells based
        on the dependency manager used to init it and stream items
        provided to create each cell.
*/
class VDirectoryContentCellFactory : VStreamContentCellFactory {
    
    //The key of the directory cell returned in the dependency manager
    private static let kDirectoryCellFactoryKey = "directoryCell"
    
    /**
        The directory cell factory subclass created from the dependency manager
            provided to this class' init
    */
    private let directoryCellFactory : VDirectoryCellFactory?
    
    required init(dependencyManager: VDependencyManager) {
        let templateValue: AnyObject! = dependencyManager.templateValueConformingToProtocol(VDirectoryCellFactory.self, forKey: VDirectoryContentCellFactory.kDirectoryCellFactoryKey)
        directoryCellFactory = templateValue as? VDirectoryCellFactory
        super.init(dependencyManager: dependencyManager)
    }
    
    override func defaultFactory() -> VStreamCellFactory? {
        return directoryCellFactory
    }

}

extension VDirectoryContentCellFactory : VDirectoryCellFactory {
 
    func minimumInterItemSpacing() -> CGFloat {
        if let factory = directoryCellFactory {
            return factory.minimumInterItemSpacing()
        }
        return 0
    }
    
    func collectionViewFlowLayout() -> VDirectoryCollectionFlowLayout? {
        return directoryCellFactory?.collectionViewFlowLayout()
    }
    
}

extension VDirectoryContentCellFactory : VDirectoryCellUpdeatableFactory {
    
    func prepareCell(cell: UICollectionViewCell, forDisplayInCollectionView collectionView: UICollectionView, atIndexPath indexPath: NSIndexPath) {
        if let factory = directoryCellFactory as? VDirectoryCellUpdeatableFactory {
            factory.prepareCell(cell, forDisplayInCollectionView: collectionView, atIndexPath: indexPath)
        }
    }
    
    func collectionViewDidScroll(collectionView: UICollectionView) {
        if let factory = directoryCellFactory as? VDirectoryCellUpdeatableFactory {
            factory.collectionViewDidScroll(collectionView)
        }
    }
    
}
