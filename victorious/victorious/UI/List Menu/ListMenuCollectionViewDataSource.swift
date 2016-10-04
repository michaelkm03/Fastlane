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
enum ListMenuSection {
    case creator
    case community
    case hashtags
    case chatRooms
}

/// Data Source for the List Menu Collection View. It does not talk to the backend.
/// To fetch data for each section, it delegates the fetching to specific data sources.
/// So if another section is added, a corresponding data source should be added too.
class ListMenuCollectionViewDataSource: NSObject, UICollectionViewDataSource, ListMenuSectionDataSourceDelegate {

    private weak var listMenuViewController: ListMenuViewController?
    private let dependencyManager: VDependencyManager
    let communityDataSource: NewListMenuSectionDataSource<ListMenuCommunityItem, SyncOperation<[ListMenuCommunityItem]>>?
    let creatorDataSource: NewListMenuSectionDataSource<UserModel, RequestOperation<CreatorListRequest>>?
    let newChatRoomsDataSource: NewListMenuSectionDataSource<ChatRoom, RequestOperation<ChatRoomsRequest>>?
    let hashtagDataSource: NewListMenuSectionDataSource<Hashtag, RequestOperation<TrendingHashtagsRequest>>?
    private let subscribeButton: SubscribeButton
    private(set) var availableSections: [ListMenuSection] = []

    // MARK: - Initialization
    
    init(dependencyManager: VDependencyManager, listMenuViewController: ListMenuViewController) {
        self.listMenuViewController = listMenuViewController
        self.dependencyManager = dependencyManager
        
        if let childDependency = dependencyManager.communityChildDependency {
            communityDataSource = NewListMenuSectionDataSource(
                dependencyManager: childDependency,
                cellConfiguration: { cell, item in cell.titleLabel.text = item.title },
                createOperation: { CommunityItemsFetchOperation(dependencyManager: childDependency) },
                processOutput: { $0 },
                section: .community
            )
            availableSections.append(.community)
        }
        else {
            communityDataSource = nil
        }

        if
            let childDependency = dependencyManager.creatorsChildDependency,
            let apiPath = childDependency.creatorsListAPIPath,
            let request = CreatorListRequest(apiPath: apiPath) {

            creatorDataSource = NewListMenuSectionDataSource(
                dependencyManager: childDependency,
                cellConfiguration: { cell, item in
                    cell.titleLabel.text = item.displayName
                    cell.avatarView.user = item
                },
                createOperation: { RequestOperation(request: request) },
                processOutput: { $0 },
                section: .creator
            )
            availableSections.append(.creator)
        }
        else {
            creatorDataSource = nil
        }

        if
            let childDependency = dependencyManager.hashtagsChildDependency,
            let apiPath = childDependency.hashtagsAPIPath,
            let request = TrendingHashtagsRequest(apiPath: apiPath) {

            hashtagDataSource = NewListMenuSectionDataSource(
                dependencyManager: childDependency,
                cellConfiguration: { cell, item in cell.titleLabel.text = item.tag },
                createOperation: { RequestOperation(request: request) },
                processOutput: { $0 },
                section: .hashtags
            )
            availableSections.append(.hashtags)
        }
        else {
            hashtagDataSource = nil
        }

        if
            let childDependency = dependencyManager.chatRoomsChildDependency,
            let apiPath = dependencyManager.chatRoomsAPIPath,
            let request = ChatRoomsRequest(apiPath: apiPath) {

            newChatRoomsDataSource = NewListMenuSectionDataSource(
                dependencyManager: childDependency,
                cellConfiguration: { cell, item in cell.titleLabel.text = item.name },
                createOperation: { RequestOperation(request: request) },
                processOutput: { $0 },
                section: .chatRooms
            )
            availableSections.append(.chatRooms)
        }
        else {
            newChatRoomsDataSource = nil
        }

        super.init()
        
        creatorDataSource?.setupDataSource(with: self)
        communityDataSource?.setupDataSource(with: self)
        hashtagDataSource?.setupDataSource(with: self)
        newChatRoomsDataSource?.setupDataSource(with: self)
        
        registerNibs(for: listMenuViewController.collectionView)
    }
    
    // MARK: - UICollectionView Data Source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return availableSections.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = availableSections[section]
        
        switch section {
            case .creator: return numberOfItems(from: creatorDataSource, in: section)
            case .community: return numberOfItems(from: communityDataSource, in: section)
            case .hashtags: return numberOfItems(from: hashtagDataSource, in: section)
            case .chatRooms: return numberOfItems(from: newChatRoomsDataSource, in: section)
        }
    }

    private func numberOfItems<Item, Request>(from dataSource: NewListMenuSectionDataSource<Item, Request>?, in section: ListMenuSection) -> Int {
        guard let dataSource = dataSource else {
            Log.error("Retrieved number of items in section for the non-existent section: \(section)")
            return 0
        }
        return dataSource.numberOfItems
    }

    func itemsIndices(for section: ListMenuSection) -> Range<Int>? {
        switch section {
            case .creator: return itemsIndices(for: creatorDataSource)
            case .community: return itemsIndices(for: communityDataSource)
            case .hashtags: return itemsIndices(for: hashtagDataSource)
            case .chatRooms: return itemsIndices(for: newChatRoomsDataSource)
        }
    }

    private func itemsIndices<Item, Request>(for dataSource: NewListMenuSectionDataSource<Item, Request>?) -> Range<Int>? {
        guard let indices = dataSource?.visibleItems.indices else {
            Log.error("Failed to get item indices for a non-existent dataSource")
            return nil
        }
        return indices
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let section = availableSections[indexPath.section]

        switch section {
            case .creator: return dequeueProperCell(from: creatorDataSource, for: collectionView, at: indexPath)
            case .community: return dequeueProperCell(from: communityDataSource, for: collectionView, at: indexPath)
            case .hashtags: return dequeueProperCell(from: hashtagDataSource, for: collectionView, at: indexPath)
            case .chatRooms: return dequeueProperCell(from: newChatRoomsDataSource, for: collectionView, at: indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerIdentifier = ListMenuSectionHeaderView.defaultReuseIdentifier
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: headerIdentifier , forIndexPath: indexPath) as! ListMenuSectionHeaderView
        let section = availableSections[indexPath.section]
        
        switch section {
            case .creator: headerView.dependencyManager = dependencyManager.creatorsChildDependency
            case .community: headerView.dependencyManager = dependencyManager.communityChildDependency
            case .hashtags: headerView.dependencyManager = dependencyManager.hashtagsChildDependency
            case .chatRooms: headerView.dependencyManager = dependencyManager.chatRoomsChildDependency
        }
        
        headerView.isSubscribeButtonHidden = indexPath.section != 0
        
        return headerView
    }
    
    // MARK: - List Menu Network Data Source Delegate
    
    func didUpdateVisibleItems(forSection section: ListMenuSection) {
        listMenuViewController?.collectionView.reloadData()
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

    private func dequeueProperCell<Item, Request>(from dataSource: NewListMenuSectionDataSource<Item, Request>?, for collectionView: UICollectionView, at indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let dataSource = dataSource else {
            Log.error("Dequeueing a proper cell for a non-existent dataSource")
            return UICollectionViewCell()
        }

        switch dataSource.state {
            case .loading: return dequeueLoadingCell(from: collectionView, at: indexPath)
            case .items: return dataSource.dequeueItemCell(from: collectionView, at: indexPath)
            case .failed, .noContent: return dequeueNoContentCell(from: collectionView, at: indexPath)
        }
    }
}

private extension VDependencyManager {
    var creatorsChildDependency: VDependencyManager? {
        return childDependencyForKey("creators")
    }

    var creatorsListAPIPath: APIPath? {
        return apiPathForKey("listOfCreatorsURL")
    }

    var communityChildDependency: VDependencyManager? {
        return childDependencyForKey("community")
    }

    var hashtagsChildDependency: VDependencyManager? {
        return childDependencyForKey("trendingHashtags")
    }

    var hashtagsAPIPath: APIPath? {
        return networkResources?.apiPathForKey("trendingHashtagsURL")
    }

    var chatRoomsChildDependency: VDependencyManager? {
        return childDependencyForKey("chat.rooms")
    }

    var chatRoomsAPIPath: APIPath? {
        return networkResources?.apiPathForKey("chat.rooms.URL")
    }
    
    var activityIndicatorColor: UIColor? {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
}
