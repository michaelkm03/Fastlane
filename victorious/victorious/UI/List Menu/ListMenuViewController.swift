//
//  ListMenuViewController.swift
//  victorious
//
//  Created by Tian Lan on 4/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

struct ListMenuSelectedItem {
    let streamAPIPath: APIPath
    let title: String?
    let context: DeeplinkContext?
    let trackingAPIPaths: [APIPath]
}

/// View Controller for the entire List Menu Component, which is currently being displayed as the left navigation pane
/// of a sliding scaffold.
class ListMenuViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CoachmarkDisplayer, VBackgroundContainer {
    
    // MARK: - Configuration
    
    private struct Constants {
        static let contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
        static let selectStreamTrackingEventName = "Select Stream"
    }
    
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
    
    static func new(withDependencyManager dependencyManager: VDependencyManager) -> ListMenuViewController {
        let viewController = self.v_initialViewControllerFromStoryboard() as ListMenuViewController
        viewController.dependencyManager = dependencyManager
        return viewController
    }
    
    // MARK: - View events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = Constants.contentInset
        dependencyManager.addBackground(toBackgroundHost: self)
        view.layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(userVIPStatusChanged), name: NSNotification.Name(rawValue: VCurrentUser.userDidUpdateNotificationKey), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView?.reloadData()

        let homeFeedIndexPath = NSIndexPath(row: 0, section: ListMenuSection.community.rawValue)
        let indexPath = lastSelectedIndexPath ?? homeFeedIndexPath
        collectionView?.selectItem(at: indexPath as IndexPath, animated: true, scrollPosition: [])
        
        dependencyManager.trackViewWillAppear(for: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dependencyManager.trackViewWillDisappear(for: self)
    }

    // MARK: - Notifications
    
    private dynamic func userVIPStatusChanged(notification: NSNotification) {
        // This allows the collection view to update the VIP button based on the new state.
        collectionView?.reloadData()
    }
    
    // MARK: - Selection
    
    private func selectCreator(atIndex index: Int) {
        guard let scaffold = VRootViewController.shared()?.scaffold as? Scaffold else {
            return
        }
        
        let creator = collectionViewDataSource.creatorDataSource.visibleItems[index]
        let destination = DeeplinkDestination(userID: creator.id)
        
        // Had to trace down the inner navigation controller because List Menu has no idea where it is - and it doesn't have navigation stack either.
        let router = Router(originViewController: scaffold.mainNavigationController, dependencyManager: dependencyManager)
        router.navigate(to: destination, from: nil)
        
        // This notification closes the side view controller
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: RESTForumNetworkSource.updateStreamURLNotification), object: nil)
    }
    
    private func selectCommunity(atIndex index: Int) {
        let item = collectionViewDataSource.communityDataSource.visibleItems[index]
        let context = DeeplinkContext(value: item.name)
        // Index 0 should correspond to the home feed, so we broadcast a nil path to denote an unfiltered feed.
        postListMenuSelection(listMenuSelection: index == 0 ? nil : ListMenuSelectedItem(
            streamAPIPath: item.streamAPIPath,
            title: item.title,
            context: context,
            trackingAPIPaths: item.trackingAPIPaths
        ))
    }
    
    private func selectHashtag(atIndex index: Int) {
        let item = collectionViewDataSource.hashtagDataSource.visibleItems[index]
        var apiPath = collectionViewDataSource.hashtagDataSource.hashtagStreamAPIPath
        apiPath.macroReplacements["%%HASHTAG%%"] = item.tag
        let context = DeeplinkContext(value: DeeplinkContext.hashTagFeed, subContext: "#\(item.tag)")
        
        let selectedTagItem = ListMenuSelectedItem(
            streamAPIPath: apiPath,
            title: "#\(item.tag)",
            context: context,
            trackingAPIPaths: collectionViewDataSource.hashtagDataSource.hashtagStreamTrackingAPIPaths.map { path in
                var path = path
                path.macroReplacements["%%HASHTAG%%"] = item.tag
                return path
            }
        )
        
        postListMenuSelection(listMenuSelection: selectedTagItem)
    }

    private func selectChatRoom(atIndex index: Int) {
        let item = collectionViewDataSource.chatRoomsDataSource.visibleItems[index]
        let itemString = item.name
        let macro = "%%CHATROOM%%"
        var apiPath = collectionViewDataSource.chatRoomsDataSource.chatRoomStreamAPIPath
        apiPath.macroReplacements[macro] = item.name
        let context = DeeplinkContext(value: DeeplinkContext.chatRoomFeed, subContext: itemString)
        let selectedItem = ListMenuSelectedItem(
            streamAPIPath: apiPath,
            title: itemString,
            context: context,
            trackingAPIPaths: collectionViewDataSource.hashtagDataSource.hashtagStreamTrackingAPIPaths.map { path in
                var path = path
                path.macroReplacements[macro] = item.name
                return path
            }
        )
        postListMenuSelection(listMenuSelection: selectedItem)
    }
    
    private func postListMenuSelection(listMenuSelection: ListMenuSelectedItem?) {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: RESTForumNetworkSource.updateStreamURLNotification),
            object: nil,
            userInfo: listMenuSelection.flatMap { ["selectedItem": $0] }
        )
        
        if let trackingAPIPaths = listMenuSelection?.trackingAPIPaths {
            VTrackingManager.sharedInstance().trackEvent(Constants.selectStreamTrackingEventName, parameters: [
                VTrackingKeyUrls: trackingAPIPaths.flatMap { $0.url?.absoluteString }
            ])
        }
    }
    
    // MARK: - UIViewController overrides
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - UICollectionView Delegate Flow Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch ListMenuSection(rawValue: indexPath.section)! {
            case .creator: return CGSize(width: view.bounds.width, height: ListMenuCreatorCollectionViewCell.preferredHeight)
            case .community: return CGSize(width: view.bounds.width, height: ListMenuCommunityCollectionViewCell.preferredHeight)
            case .hashtags: return CGSize(width: view.bounds.width, height: ListMenuHashtagCollectionViewCell.preferredHeight)
            case .chatRooms: return CGSize(width: view.bounds.width, height: ListMenuChatRoomCollectionViewCell.preferredHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 0, bottom: 24, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.bounds.width, height: ListMenuSectionHeaderView.preferredHeight)
    }
    
    // MARK: - UICollectionView Delegate
    
    private var lastSelectedIndexPath: NSIndexPath?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let listMenuSection = ListMenuSection(rawValue: indexPath.section)!
        
        switch listMenuSection {
            case .creator:
                selectCreator(atIndex: indexPath.item)
                
                // Hack to get the selection to work. Otherwise, the previous state would not appear to be selected
                // until touching the collectionView.
                collectionView.performBatchUpdates(nil, completion: { [weak self] _ in
                    collectionView.selectItem(
                        at: self?.lastSelectedIndexPath as IndexPath?,
                        animated: true,
                        scrollPosition: []
                    )
                })
            case .community:
                selectCommunity(atIndex: indexPath.item)
                lastSelectedIndexPath = indexPath as NSIndexPath?
            case .hashtags:
                selectHashtag(atIndex: indexPath.item)
                lastSelectedIndexPath = indexPath as NSIndexPath?
            case .chatRooms:
                selectChatRoom(atIndex: indexPath.item)
                lastSelectedIndexPath = indexPath as NSIndexPath?
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let validIndices: CountableRange<Int>
        
        switch ListMenuSection(rawValue: indexPath.section)! {
            case .creator: validIndices = collectionViewDataSource.creatorDataSource.visibleItems.indices
            case .community: validIndices = collectionViewDataSource.communityDataSource.visibleItems.indices
            case .hashtags: validIndices = collectionViewDataSource.hashtagDataSource.visibleItems.indices
            case .chatRooms: validIndices = collectionViewDataSource.chatRoomsDataSource.visibleItems.indices
        }
        return validIndices ~= indexPath.row
    }
    
    // MARK: - CoachmarkDisplayer
    
    func highlightFrame(forIdentifier: String) -> CGRect? {
        return nil 
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return view
    }
}
