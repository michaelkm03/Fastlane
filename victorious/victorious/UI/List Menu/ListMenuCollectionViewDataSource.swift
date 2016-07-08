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
    
    let communityDataSource: ListMenuCommunityDataSource
    let hashtagDataSource: ListMenuHashtagDataSource
    let creatorDataSource: ListMenuCreatorDataSource
    
    private lazy var subscribeButton: UIButton = {
        let button = BackgroundButton()
        button.tintColor = self.dependencyManager.subscribeButtonTextColor
        button.backgroundColor = self.dependencyManager.subscribeButtonBackgroundColor
        button.titleLabel?.font = self.dependencyManager.subscribeButtonFont
        button.addTarget(self, action: #selector(onSubscribePressed), forControlEvents: .TouchUpInside)
        button.setTitle(NSLocalizedString("Upgrade", comment: ""), forState: .Normal)
        return button
    }()
    
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
        
        registerNibs(for: listMenuViewController.collectionView)
    }
    
    // MARK: - UICollectionView Data Source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return ListMenuSection.numberOfSections
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let listMenuSection = ListMenuSection(rawValue: section)!
        
        switch listMenuSection {
        case .creator:
            return creatorDataSource.numberOfItems
        case .community:
            return communityDataSource.numberOfItems
        case .hashtags:
            return hashtagDataSource.numberOfItems
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let listMenuSection = ListMenuSection(rawValue: indexPath.section)!

        switch listMenuSection {
            
        case .creator:
            return dequeueProperCell(creatorDataSource, for: collectionView, at: indexPath)
        case .community:
            return dequeueProperCell(communityDataSource, for: collectionView, at: indexPath)
        case .hashtags:
            return dequeueProperCell(hashtagDataSource, for: collectionView, at: indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerIdentifier = ListMenuSectionHeaderView.defaultReuseIdentifier
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

        // A custom accessoryButton is added to the first headerView to allow entry into the VIPForum and is not related to the actual section header.
        headerView.accessoryButton = indexPath.section == 0 ? subscribeButton : nil
        
        return headerView
    }
    
    // MARK: - Actions
    
    @objc private func onSubscribePressed() {
        guard let scaffold = VRootViewController.sharedRootViewController()?.scaffold else {
            return
        }
        let router = Router(originViewController: scaffold, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination.vipForum
        router.navigate(to: destination)
    }
    
    // MARK: - List Menu Network Data Source Delegate
    
    func didUpdateVisibleItems(forSection section: ListMenuSection) {
        listMenuViewController.collectionView.reloadData()
    }
    
    // MARK: - Private Methods
    
    private func registerNibs(for collectionView: UICollectionView) {
        let identifier = ActivityIndicatorCollectionCell.defaultReuseIdentifier
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass: ActivityIndicatorCollectionCell.self) )
        collectionView.registerNib(nib, forCellWithReuseIdentifier: identifier)
    }
    
    private func dequeueLoadingCell(from collectionView: UICollectionView, at indexPath: NSIndexPath) -> ActivityIndicatorCollectionCell {
        let loadingCell = collectionView.dequeueReusableCellWithReuseIdentifier(ActivityIndicatorCollectionCell.defaultReuseIdentifier, forIndexPath: indexPath) as! ActivityIndicatorCollectionCell
        loadingCell.color = dependencyManager.activityIndicatorColor
        
        return loadingCell
    }
    
    private func dequeueNoContentCell(from collectionView: UICollectionView, at indexPath: NSIndexPath) -> UICollectionViewCell {
        let noContentCell = collectionView.dequeueReusableCellWithReuseIdentifier(ListMenuNoContentCollectionViewCell.defaultReuseIdentifier, forIndexPath: indexPath) as! ListMenuNoContentCollectionViewCell
        
        noContentCell.dependencyManager = dependencyManager
        noContentCell.configure(withTitle: NSLocalizedString("No results", comment: "List Menu failed to load results for a section, e.g. creators, communities or trending hashtags"))
        
        return noContentCell
    }

    private func dequeueProperCell<DataSource: ListMenuSectionDataSource where DataSource.Cell: UICollectionViewCell>(dataSource: DataSource, for collectionView: UICollectionView, at indexPath: NSIndexPath) -> UICollectionViewCell {
        switch dataSource.state {
        case .loading:
            return dequeueLoadingCell(from: collectionView, at: indexPath)
        case .items:
            return dataSource.dequeueItemCell(from: collectionView, at: indexPath)
        case .failed, .noContent:
            return dequeueNoContentCell(from: collectionView, at: indexPath)
        }
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
        return self.childDependencyForKey("trendingHashtags") ?? self
    }
    
    var activityIndicatorColor: UIColor? {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    // FUTURE: Make this styled via template once available
    
    var subscribeButtonFont: UIFont? {
        return UIFont.systemFontOfSize(14.0, weight: UIFontWeightSemibold)
    }
    
    var subscribeButtonTextColor: UIColor? {
        return UIColor(white: 1.0, alpha: 1.0)
    }
    
    var subscribeButtonBackgroundColor: UIColor? {
        return UIColor(white: 1.0, alpha: 0.15)
    }
}
