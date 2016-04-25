//
//  ListMenuCollectionViewDataSource.swift
//  victorious
//
//  Created by Tian Lan on 4/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// The enum for different sections of List Menu
/// If you add a section, please make sure to update `numberOfSections` too
enum ListMenuSection: Int {
    case creator
    case community
    case hashtags
    
    static var numberOfSections: Int {
        return 3
    }
}

/// Data Source for the List Menu Collection View. It does not talk to the backend.
/// To fetch data for each section, it delegates the fetching to specific data sources.
/// So if another section is added, a corresponding data source should be added too.
class ListMenuCollectionViewDataSource: NSObject, UICollectionViewDataSource, ListMenuSectionDataSourceDelegate {
    
    private let listMenuViewController: ListMenuViewController
    private let dependencyManager: VDependencyManager
    
    private let communityDataSource: ListMenuCommunityDataSource
    private let hashtagDataSource: ListMenuHashtagDataSource
    private let creatorDataSource: ListMenuCreatorDataSource
    
    // MARK: - Initialization
    
    init(dependencyManager: VDependencyManager, listMenuViewController: ListMenuViewController) {
        self.listMenuViewController = listMenuViewController
        self.dependencyManager = dependencyManager
        
        creatorDataSource = ListMenuCreatorDataSource(dependencyManager: dependencyManager.creatorsChildDependency)
        communityDataSource = ListMenuCommunityDataSource(dependencyManager: dependencyManager.communityChildDependency)
        hashtagDataSource = ListMenuHashtagDataSource(dependencyManager: dependencyManager.hashtagsChildDependency)
        
        super.init()
        
        creatorDataSource.setupDataSource(with: self)
        communityDataSource.setupDataSource(with: self)
        hashtagDataSource.setupDataSource(with: self)
    }
    
    // MARK: - UICollectionView Data Source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return ListMenuSection.numberOfSections
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let listMenuSection = ListMenuSection(rawValue: section)!
        
        switch listMenuSection {
        case .creator:
            return creatorDataSource.visibleItems.count
        case .community:
            return communityDataSource.visibleItems.count
        case .hashtags:
            return hashtagDataSource.visibleItems.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let listMenuSection = ListMenuSection(rawValue: indexPath.section)!
        
        switch listMenuSection {
            
        case .creator:
            return creatorDataSource.dequeueCell(from: collectionView, for: indexPath)
        
        case .community:
            return communityDataSource.dequeueCell(from: collectionView, for: indexPath)
        
        case .hashtags:
            return hashtagDataSource.dequeueCell(from: collectionView, for: indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerIdentifier = stringFromClass(ListMenuSectionHeaderView.self)
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: headerIdentifier , forIndexPath: indexPath) as! ListMenuSectionHeaderView
        let listMenuSection = ListMenuSection(rawValue: indexPath.section)!
        
        switch listMenuSection {
        case .creator:
            headerView.dependencyManager = dependencyManager.creatorsChildDependency
        case .community:
            headerView.dependencyManager = dependencyManager.communityChildDependency
        case .hashtags:
            headerView.dependencyManager = dependencyManager.hashtagsChildDependency
        }
        
        return headerView
    }
    
    // MARK: - List Menu Network Data Source Delegate
    
    func didUpdateVisibleItems(forSection section: ListMenuSection) {
        listMenuViewController.collectionView.reloadData()
    }
}

private extension VDependencyManager {
    
    var creatorsChildDependency: VDependencyManager {
        return self.childDependencyForKey("creators") ?? self
    }
    
    var communityChildDependency: VDependencyManager {
        return self.childDependencyForKey("community") ?? self
    }
    
    var hashtagsChildDependency: VDependencyManager {
        return self.childDependencyForKey("trending") ?? self
    }
}
