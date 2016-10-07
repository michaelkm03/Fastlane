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
    var streamAPIPath: APIPath
    var chatRoomID: ChatRoom.ID?
    var title: String?
    var context: DeeplinkContext?
    var trackingAPIPaths: [APIPath]
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

        if let sectionIndex = collectionViewDataSource.availableSections.index(of: .community) {
            let homeFeedIndexPath = IndexPath(row: 0, section: sectionIndex)
            let indexPath = lastSelectedIndexPath ?? homeFeedIndexPath
            collectionView?.selectItem(at: indexPath as IndexPath, animated: true, scrollPosition: [])
        }

        dependencyManager.trackViewWillAppear(for: self)
        
        // This prevents issues with the list menu's layout receiving implicit animation when it's opened.
        UIView.performWithoutAnimation {
            view.layoutIfNeeded()
        }
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
        guard
            let scaffold = VRootViewController.shared()?.scaffold as? Scaffold,
            let creator = collectionViewDataSource.creatorsDataSource?.visibleItems[index]
        else {
            Log.warning("Trying to select a non existing section at index \(index)")
            return
        }

        let destination = DeeplinkDestination(userID: creator.id)
        // Had to trace down the inner navigation controller because List Menu has no idea where it is - and it doesn't have navigation stack either.
        let router = Router(originViewController: scaffold.mainNavigationController, dependencyManager: dependencyManager)
        router.navigate(to: destination, from: nil)

        // This notification closes the side view controller
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: RESTForumNetworkSource.updateStreamURLNotification), object: nil)
    }

    private func selectCommunity(atIndex index: Int) {
        guard let item = collectionViewDataSource.communityDataSource?.visibleItems[index] else {
            Log.warning("Trying to select a non existing section at index \(index)")
            return
        }
        let context = DeeplinkContext(value: item.name)
        // Index 0 should correspond to the home feed, so we broadcast a nil path to denote an unfiltered feed.
        postListMenuSelection(index == 0 ? nil : ListMenuSelectedItem(
            streamAPIPath: item.streamAPIPath,
            chatRoomID: nil,
            title: item.title,
            context: context,
            trackingAPIPaths: item.trackingAPIPaths
        ))
    }

    private func selectHashtag(atIndex index: Int) {
        guard
            let item = collectionViewDataSource.hashtagDataSource?.visibleItems[index],
            var apiPath = collectionViewDataSource.hashtagDataSource?.streamAPIPath,
            let trackingAPIPaths = collectionViewDataSource.hashtagDataSource?.streamTrackingAPIPaths
        else {
            Log.error("Trying to select a hashtag with incomplete data")
            return
        }
        apiPath.macroReplacements["%%HASHTAG%%"] = item.tag
        let context = DeeplinkContext(value: DeeplinkContext.hashTagFeed, subContext: "#\(item.tag)")

        let selectedTagItem = ListMenuSelectedItem(
            streamAPIPath: apiPath,
            chatRoomID: nil,
            title: "#\(item.tag)",
            context: context,
            trackingAPIPaths: trackingAPIPaths.map { path in
                var path = path
                path.macroReplacements["%%HASHTAG%%"] = item.tag
                return path
            }
        )
        
        postListMenuSelection(selectedTagItem)
    }

    private func selectChatRoom(atIndex index: Int) {
        guard
            let chatRoom = collectionViewDataSource.chatRoomsDataSource?.visibleItems[index],
            var streamAPIPath = collectionViewDataSource.chatRoomsDataSource?.streamAPIPath,
            let trackingAPIPaths = collectionViewDataSource.hashtagDataSource?.streamTrackingAPIPaths
        else {
            Log.error("Trying to select a chat room with incomplete data")
            return
        }
        
        let macro = "%%ROOM_ID%%"
        streamAPIPath.macroReplacements[macro] = chatRoom.name
        let context = DeeplinkContext(value: DeeplinkContext.chatRoomFeed, subContext: chatRoom.name)
        
        let selectedItem = ListMenuSelectedItem(
            streamAPIPath: streamAPIPath,
            chatRoomID: chatRoom.id,
            title: chatRoom.name,
            context: context,
            trackingAPIPaths: trackingAPIPaths.map { path in
                var path = path
                path.macroReplacements[macro] = chatRoom.name
                return path
            }
        )
        
        postListMenuSelection(selectedItem)
    }
    
    private func postListMenuSelection(_ listMenuSelection: ListMenuSelectedItem?) {
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
        return CGSize(width: view.bounds.width, height: ListMenuSectionCell.preferredHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 0, bottom: 24, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.bounds.width, height: ListMenuSectionHeaderView.preferredHeight)
    }

    // MARK: - UICollectionView Delegate

    private var lastSelectedIndexPath: IndexPath?

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = collectionViewDataSource.availableSections[indexPath.section]

        switch section {
            case .creators:
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
                lastSelectedIndexPath = indexPath as IndexPath?
            case .hashtags:
                selectHashtag(atIndex: indexPath.item)
                lastSelectedIndexPath = indexPath as IndexPath?
            case .chatRooms:
                selectChatRoom(atIndex: indexPath.item)
                lastSelectedIndexPath = indexPath as IndexPath?
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let validIndices: CountableRange<Int>?
        let section = collectionViewDataSource.availableSections[indexPath.section]
        validIndices = collectionViewDataSource.itemsIndices(for: section)
        if let validIndices = validIndices {
            return validIndices ~= indexPath.row
        }
        else {
            return false
        }
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
