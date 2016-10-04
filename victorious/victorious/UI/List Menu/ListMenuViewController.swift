//
//  ListMenuViewController.swift
//  victorious
//
//  Created by Tian Lan on 4/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

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
    
    static func newWithDependencyManager(dependencyManager: VDependencyManager) -> ListMenuViewController {
        let viewController = self.v_initialViewControllerFromStoryboard() as ListMenuViewController
        viewController.dependencyManager = dependencyManager
        return viewController
    }
    
    // MARK: - View events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = Constants.contentInset
        dependencyManager.addBackgroundToBackgroundHost(self)
        view.layoutIfNeeded()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userVIPStatusChanged), name: VCurrentUser.userDidUpdateNotificationKey, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView?.reloadData()

        if let sectionIndex = collectionViewDataSource.availableSections.indexOf(.community) {
            let homeFeedIndexPath = NSIndexPath(forRow: 0, inSection: sectionIndex)
            let indexPath = lastSelectedIndexPath ?? homeFeedIndexPath
            collectionView?.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
        
        dependencyManager.trackViewWillAppear(for: self)
    }
    
    override func viewWillDisappear(animated: Bool) {
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
            let scaffold = VRootViewController.sharedRootViewController()?.scaffold as? Scaffold,
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
        NSNotificationCenter.defaultCenter().postNotificationName(
            RESTForumNetworkSource.updateStreamURLNotification,
            object: nil,
            userInfo: nil
        )
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
            let item = collectionViewDataSource.newChatRoomsDataSource?.visibleItems[index],
            var apiPath = collectionViewDataSource.newChatRoomsDataSource?.streamAPIPath,
            let trackingAPIPaths = collectionViewDataSource.hashtagDataSource?.streamTrackingAPIPaths
        else {
            Log.error("Trying to select a chat room with incomplete data")
            return
        }
        let itemString = item.name
        let macro = "%%CHATROOM%%"
        apiPath.macroReplacements[macro] = item.name
        let context = DeeplinkContext(value: DeeplinkContext.chatRoomFeed, subContext: itemString)
        let selectedItem = ListMenuSelectedItem(
            streamAPIPath: apiPath,
            title: itemString,
            context: context,
            trackingAPIPaths: trackingAPIPaths.map { path in
                var path = path
                path.macroReplacements[macro] = item.name
                return path
            }
        )
        postListMenuSelection(selectedItem)
    }
    
    private func postListMenuSelection(listMenuSelection: ListMenuSelectedItem?) {
        NSNotificationCenter.defaultCenter().postNotificationName(
            RESTForumNetworkSource.updateStreamURLNotification,
            object: nil,
            userInfo: listMenuSelection.flatMap { ["selectedItem": ReferenceWrapper($0)] }
        )
        
        if let trackingAPIPaths = listMenuSelection?.trackingAPIPaths {
            VTrackingManager.sharedInstance().trackEvent(Constants.selectStreamTrackingEventName, parameters: [
                VTrackingKeyUrls: trackingAPIPaths.flatMap { $0.url?.absoluteString }
            ])
        }
    }
    
    // MARK: - UIViewController overrides
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    // MARK: - UICollectionView Delegate Flow Layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: view.bounds.width, height: NewListMenuSectionCell.preferredHeight)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 0, bottom: 24, right: 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.bounds.width, height: ListMenuSectionHeaderView.preferredHeight)
    }
    
    // MARK: - UICollectionView Delegate
    
    private var lastSelectedIndexPath: NSIndexPath?
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let section = collectionViewDataSource.availableSections[indexPath.section]

        switch section {
            case .creators:
                selectCreator(atIndex: indexPath.item)
                
                // Hack to get the selection to work. Otherwise, the previous state would not appear to be selected
                // until touching the collectionView.
                collectionView.performBatchUpdates(nil, completion: { [weak self] _ in
                    collectionView.selectItemAtIndexPath(
                        self?.lastSelectedIndexPath,
                        animated: true,
                        scrollPosition: .None
                    )
                })
            case .community:
                selectCommunity(atIndex: indexPath.item)
                lastSelectedIndexPath = indexPath
            case .hashtags:
                selectHashtag(atIndex: indexPath.item)
                lastSelectedIndexPath = indexPath
            case .chatRooms:
                selectChatRoom(atIndex: indexPath.item)
                lastSelectedIndexPath = indexPath
        }
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let validIndices: Range<Int>?
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
    
    func highlightFrame(forIdentifier forIdentifier: String) -> CGRect? {
        return nil 
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return view
    }
}
