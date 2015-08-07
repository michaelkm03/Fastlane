//
//  VDirectroyStreamContentCellFactory.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

struct constants {
    static let kDirectoryCellFactoryKey = "directoryCell"
}

class VDirectoryContentCellFactory : VStreamContentCellFactory, VDirectoryCellFactory, VDirectoryCellFactoryUpdatable {
    
    let directoryCellFactory : VDirectoryCellFactory?
    
    required init(dependencyManager: VDependencyManager) {
        let templateValue: AnyObject! = dependencyManager.templateValueConformingToProtocol(VDirectoryCellFactory.self, forKey: constants.kDirectoryCellFactoryKey)
        directoryCellFactory = templateValue as? VDirectoryCellFactory
        super.init(dependencyManager: dependencyManager)
        defaultFactory = directoryCellFactory
    }
    
    func minimumInterItemSpacing() -> CGFloat {
        if let factory = directoryCellFactory {
            return factory.minimumInterItemSpacing()
        }
        return 0
    }
    
    func collectionViewFlowLayout() -> VDirectoryCollectionFlowLayout? {
        return directoryCellFactory?.collectionViewFlowLayout()
    }
    
    func prepareCell(cell: UICollectionViewCell, forDisplayInCollectionView collectionView: UICollectionView, atIndexPath indexPath: NSIndexPath) {
        if let factory = directoryCellFactory as? VDirectoryCellFactoryUpdatable {
            factory.prepareCell(cell, forDisplayInCollectionView: collectionView, atIndexPath: indexPath)
        }
    }
    
    func collectionViewDidScroll(collectionView: UICollectionView) {
        if let factory = directoryCellFactory as? VDirectoryCellFactoryUpdatable {
            factory.collectionViewDidScroll(collectionView)
        }
    }
}
