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
    
    private lazy var hashtagDataSource: ListMenuHashtagDataSource? = {
        guard let childDependency = self.dependencyManager.childDependencyForKey(self.dependencyManager.trendingHashtagsKey) else {
            assertionFailure("List menu is missing trending hashtags child dependency")
            return nil
        }
        return ListMenuHashtagDataSource(dependencyManager: childDependency, delegate: self)
    }()
    
    // MARK: - Initialization
    
    init(dependencyManager: VDependencyManager, listMenuViewController: ListMenuViewController) {
        self.listMenuViewController = listMenuViewController
        self.dependencyManager = dependencyManager
        
        super.init()
    }
    
    // MARK: - UICollectionView Data Source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return ListMenuSection.numberOfSections
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let listMenuSection = ListMenuSection(rawValue: section)!
        
        switch listMenuSection {
        case .creator:
            return 0
        case .community:
            return 0
        case .hashtags:
            return hashtagDataSource?.visibleItems.count ?? 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let listMenuSection = ListMenuSection(rawValue: indexPath.section)!
        
        switch listMenuSection {
        case .creator:
            return UICollectionViewCell()
        case .community:
            return UICollectionViewCell()
        case .hashtags:
            let hashtagCell = collectionView.dequeueReusableCellWithReuseIdentifier(ListMenuHashtagCollectionViewCell.defaultSwiftReuseIdentifier, forIndexPath: indexPath) as! ListMenuHashtagCollectionViewCell
            if let hashtag = hashtagDataSource?.visibleItems[indexPath.item] {
                hashtagCell.configureCell(with: hashtag)
            }
            
            return hashtagCell
        }
    }
    
    // MARK: - List Menu Network Data Source Delegate
    
    func didUpdateVisibleItems(forSection section: ListMenuSection) {
        listMenuViewController.collectionView.reloadSections(NSIndexSet(index: section.rawValue))
    }
}

private extension VDependencyManager {
    var creatorsKey: String {
        return "creators"
    }
    var communityKey: String {
        return "community"
    }
    var trendingHashtagsKey: String {
       return "trending"
    }
}
