//
//  ListMenuCollectionViewDataSource.swift
//  victorious
//
//  Created by Tian Lan on 4/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

/// The enum for different sections of List Menu
/// If you add a section, please make sure to update `numberOfSections` too
enum ListMenuSection: Int {
    case creator
    case community
    case hashtags
    case chatRooms

    static var numberOfSections: Int {
        return 4
    }
}

/// Data Source for the List Menu Collection View. It does not talk to the backend.
/// To fetch data for each section, it delegates the fetching to specific data sources.
/// So if another section is added, a corresponding data source should be added too.
class ListMenuCollectionViewDataSource: NSObject, UICollectionViewDataSource, ListMenuSectionDataSourceDelegate {
    private weak var listMenuViewController: ListMenuViewController?
    private let dependencyManager: VDependencyManager
    
    let communityDataSource: ListMenuCommunityDataSource
    let hashtagDataSource: ListMenuHashtagsDataSource
    let creatorDataSource: ListMenuCreatorDataSource
    let chatRoomsDataSource: ListMenuChatRoomsDataSource
    
    private let subscribeButton: SubscribeButton
    
    // MARK: - Initialization
    
    init(dependencyManager: VDependencyManager, listMenuViewController: ListMenuViewController) {
        self.listMenuViewController = listMenuViewController
        self.dependencyManager = dependencyManager
        subscribeButton = SubscribeButton(dependencyManager: dependencyManager)
        
        creatorDataSource = ListMenuCreatorDataSource(dependencyManager: dependencyManager.creatorsChildDependency)
        communityDataSource = ListMenuCommunityDataSource(dependencyManager: dependencyManager.communityChildDependency)
        hashtagDataSource = ListMenuHashtagsDataSource(dependencyManager: dependencyManager.hashtagsChildDependency)
        chatRoomsDataSource = ListMenuChatRoomsDataSource(dependencyManager: dependencyManager.chatRoomsChildDependency)

        super.init()
        
        creatorDataSource.setupDataSource(with: self)
        communityDataSource.setupDataSource(with: self)
        hashtagDataSource.setupDataSource(with: self)
        chatRoomsDataSource.setupDataSource(with: self)
        
        registerNibs(for: listMenuViewController.collectionView)
    }
    
    // MARK: - UICollectionView Data Source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return ListMenuSection.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let listMenuSection = ListMenuSection(rawValue: section)!
        
        switch listMenuSection {
            case .creator: return creatorDataSource.numberOfItems
            case .community: return communityDataSource.numberOfItems
            case .hashtags: return hashtagDataSource.numberOfItems
            case .chatRooms: return chatRoomsDataSource.numberOfItems
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let listMenuSection = ListMenuSection(rawValue: indexPath.section)!

        switch listMenuSection {
            case .creator: return dequeueProperCell(dataSource: creatorDataSource, for: collectionView, at: indexPath)
            case .community: return dequeueProperCell(dataSource: communityDataSource, for: collectionView, at: indexPath)
            case .hashtags: return dequeueProperCell(dataSource: hashtagDataSource, for: collectionView, at: indexPath)
            case .chatRooms: return dequeueProperCell(dataSource: chatRoomsDataSource, for: collectionView, at: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerIdentifier = ListMenuSectionHeaderView.defaultReuseIdentifier
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier , for: indexPath as IndexPath) as! ListMenuSectionHeaderView
        let listMenuSection = ListMenuSection(rawValue: indexPath.section)!
        
        switch listMenuSection {
            case .creator: headerView.dependencyManager = dependencyManager.creatorsChildDependency
            case .community: headerView.dependencyManager = dependencyManager.communityChildDependency
            case .hashtags: headerView.dependencyManager = dependencyManager.hashtagsChildDependency
            case .chatRooms: headerView.dependencyManager = dependencyManager.chatRoomsChildDependency
        }
        
        headerView.accessoryView = indexPath.section == 0 ? subscribeButton : nil
        return headerView
    }
    
    // MARK: - List Menu Network Data Source Delegate
    
    func didUpdateVisibleItems(forSection section: ListMenuSection) {
        listMenuViewController?.collectionView.reloadData()
    }
    
    // MARK: - Private Methods
    
    private func registerNibs(for collectionView: UICollectionView) {
        let identifier = ActivityIndicatorCollectionCell.defaultReuseIdentifier
        let nib = UINib(nibName: identifier, bundle: Bundle(for: ActivityIndicatorCollectionCell.self) )
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    private func dequeueLoadingCell(from collectionView: UICollectionView, at indexPath: IndexPath) -> ActivityIndicatorCollectionCell {
        let loadingCell = collectionView.dequeueReusableCell(withReuseIdentifier: ActivityIndicatorCollectionCell.defaultReuseIdentifier, for: indexPath as IndexPath) as! ActivityIndicatorCollectionCell
        loadingCell.color = dependencyManager.activityIndicatorColor
        return loadingCell
    }
    
    private func dequeueNoContentCell(from collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let noContentCell = collectionView.dequeueReusableCell(withReuseIdentifier: ListMenuNoContentCollectionViewCell.defaultReuseIdentifier, for: indexPath as IndexPath) as! ListMenuNoContentCollectionViewCell
        
        noContentCell.dependencyManager = dependencyManager
        noContentCell.configure(withTitle: NSLocalizedString("No results", comment: "List Menu failed to load results for a section, e.g. creators, communities or trending hashtags"))
        
        return noContentCell
    }

    private func dequeueProperCell<DataSource: ListMenuSectionDataSource>(dataSource: DataSource, for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell where DataSource.Cell: UICollectionViewCell {
        switch dataSource.state {
            case .loading: return dequeueLoadingCell(from: collectionView, at: indexPath)
            case .items: return dataSource.dequeueItemCell(from: collectionView, at: indexPath)
            case .failed, .noContent: return dequeueNoContentCell(from: collectionView, at: indexPath)
        }
    }
}

private extension VDependencyManager {
    var creatorsChildDependency: VDependencyManager {
        return self.childDependency(forKey: "creators") ?? self
    }
    
    var communityChildDependency: VDependencyManager {
        return self.childDependency(forKey: "community") ?? self
    }
    
    var hashtagsChildDependency: VDependencyManager {
        return self.childDependency(forKey: "trendingHashtags") ?? self
    }

    var chatRoomsChildDependency: VDependencyManager {
        return self.childDependency(forKey: "chat.rooms") ?? self
    }
    
    var activityIndicatorColor: UIColor? {
        return color(forKey: VDependencyManagerMainTextColorKey)
    }
}
