//
//  ListMenuViewController.swift
//  victorious
//
//  Created by Tian Lan on 4/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// View Controller for the entire List Menu Component, which is currently being displayed as the left navigation pane
/// of a sliding scaffold.
class ListMenuViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, VCoachmarkDisplayer, VNavigationDestination, VBackgroundContainer {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = collectionViewDataSource
            collectionView.delegate = self
        }
    }
    
    var dependencyManager: VDependencyManager!
    
    private lazy var collectionViewDataSource: ListMenuCollectionViewDataSource = {
        ListMenuCollectionViewDataSource(dependencyManager: self.dependencyManager, listMenuViewController: self)
    }()
    
    // MARK: - Initialization
    
    static func newWithDependencyManager(dependencyManager: VDependencyManager) -> ListMenuViewController {
        let viewController = self.v_initialViewControllerFromStoryboard() as ListMenuViewController
        viewController.dependencyManager = dependencyManager
        dependencyManager.addBackgroundToBackgroundHost(viewController)
        
        return viewController
    }
    
    // MARK: - View events
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if collectionView?.indexPathsForSelectedItems()?.isEmpty != false {
            let indexPath = NSIndexPath(forRow: 0, inSection: ListMenuSection.community.rawValue)
            collectionView?.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
    }
    
    // MARK: - Notifications
    
    private func selectCreator(atIndex index: Int) {
        let creator = collectionViewDataSource.creatorDataSource.visibleItems[index]
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        router.navigate(to: creator.id)
        
        // This notification closes the side view controller
        NSNotificationCenter.defaultCenter().postNotificationName(
            RESTForumNetworkSource.updateStreamURLNotification,
            object: nil,
            userInfo: nil
        )
    }
    
    private func selectCommunity(atIndex index: Int) {
        let item = collectionViewDataSource.communityDataSource.visibleItems[index]
        
        // Index 0 should correspond to the home feed, so we broadcast a nil path to denote an unfiltered feed.
        postStreamAPIPath(index == 0 ? nil : item.streamAPIPath)
    }
    
    private func selectHashtag(atIndex index: Int) {
        let item = collectionViewDataSource.hashtagDataSource.visibleItems[index]
        var apiPath = collectionViewDataSource.hashtagDataSource.hashtagStreamAPIPath
        apiPath.macroReplacements["%%HASHTAG%%"] = item.tag
        postStreamAPIPath(apiPath)
    }
    
    private func postStreamAPIPath(streamAPIPath: APIPath?) {
        NSNotificationCenter.defaultCenter().postNotificationName(
            RESTForumNetworkSource.updateStreamURLNotification,
            object: nil,
            userInfo: streamAPIPath.flatMap { ["streamAPIPath": ReferenceWrapper($0)] }
        )
    }
    
    // MARK: - UIViewController overrides
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    // MARK: - UICollectionView Delegate Flow Layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch ListMenuSection(rawValue: indexPath.section)! {
            case .creator: return CGSize(width: view.bounds.width, height: ListMenuCreatorCollectionViewCell.preferredHeight)
            case .community: return CGSize(width: view.bounds.width, height: ListMenuCommunityCollectionViewCell.preferredHeight)
            case .hashtags: return CGSize(width: view.bounds.width, height: ListMenuHashtagCollectionViewCell.preferredHeight)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 0, bottom: 24, right: 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.bounds.width, height: ListMenuSectionHeaderView.preferredHeight)
    }
    
    // MARK: - UICollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let listMenuSection = ListMenuSection(rawValue: indexPath.section)!
        
        switch listMenuSection {
            case .creator: selectCreator(atIndex: indexPath.item)
            case .community: selectCommunity(atIndex: indexPath.item)
            case .hashtags: selectHashtag(atIndex: indexPath.item)
        }
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let validIndices: Range<Int>
        
        switch ListMenuSection(rawValue: indexPath.section)! {
            case .creator: validIndices = collectionViewDataSource.creatorDataSource.visibleItems.indices
            case .community: validIndices = collectionViewDataSource.communityDataSource.visibleItems.indices
            case .hashtags: validIndices = collectionViewDataSource.hashtagDataSource.visibleItems.indices
        }
        
        return validIndices ~= indexPath.row
    }
    
    // MARK - VCoachmarkDisplayer
    
    func screenIdentifier() -> String! {
        return dependencyManager.stringForKey(VDependencyManagerIDKey)
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return view
    }
}
