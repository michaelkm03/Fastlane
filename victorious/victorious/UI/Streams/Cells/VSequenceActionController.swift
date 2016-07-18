//
//  VSequenceActionController+Actions.swift
//  victorious
//
//  Created by Vincent Ho on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc class VSequenceActionController: NSObject {
    
    let dependencyManager: VDependencyManager
    let originViewController: UIViewController
    private var remixPresenter: VRemixPresenter?
    
    private(set) weak var delegate: VSequenceActionControllerDelegate?
    
    //  MARK: - Initializer
    
    /// Sets up the SequenceActionController with the dependency manager and the view controller on
    /// which it should be presented.
    init(dependencyManager: VDependencyManager, originViewController: UIViewController, delegate: VSequenceActionControllerDelegate) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.delegate = delegate
        super.init()
    }
    
    /// Presents a VActionSheetViewController set up with options based off of the VSequence object provided.
    func showMoreWithSequence(sequence: VSequence, streamId: String?, completion: (() -> ())? ) {
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectMoreActions, parameters: [VTrackingKeySequenceId: sequence.remoteId])
        
        let actionSheetViewController = VActionSheetViewController()
        actionSheetViewController.dependencyManager = dependencyManager
        VActionSheetTransitioningDelegate.addNewTransitioningDelegateToActionSheetController(actionSheetViewController)
        setupActionSheetViewController(actionSheetViewController, sequence: sequence, streamId: streamId)
        originViewController.presentViewController(actionSheetViewController, animated: true) {
            completion?()
        }
    }
    
    //   MARK: - Show Media
    
    func showMediaContent(mediaUrl: NSURL, mediaLinkType linkType: VCommentMediaType) {
        ShowMediaContentOperation(originViewController: originViewController,
                                mediaUrl: mediaUrl,
                                mediaLinkType: linkType).queue()
    }
    
    // MARK: - Remix
    
    func showRemixWithSequence(sequence: VSequence) {
        assert(!sequence.isPoll(), "You cannot remix polls.")
        
        remixPresenter = VRemixPresenter(dependencyManager: dependencyManager, sequenceToRemix: sequence)
        remixPresenter?.presentOnViewController(originViewController)
    }
    
    // MARK: - User
    
    func showProfileWithRemoteId(userId: Int) {
        let router = Router(originViewController: originViewController, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(userID: userId)
        router.navigate(to: destination)
    }
    
    // MARK: - Share
    
    func shareSequence(sequence: VSequence, streamID: String?, completion: (() -> ())? ) {
        ShowShareSequenceOperation(originViewController: originViewController,
                                   dependencyManager: dependencyManager,
                                   sequence: sequence,
                                   streamID: streamID).queue() { error, cancelled in
                                       completion?()
        }
    }
    
    // MARK: - Comments
    
    func showCommentsWithSequence(sequence: VSequence) {
        ShowCommentsOperation(originViewController: originViewController, dependencyManager: dependencyManager, sequence: sequence).queue()
    }
    
    // MARK: - Flag
    
    /// Presents an Alert Controller to confirm flagging of a sequence. Upon confirmation, flags the
    /// sequence and calls the completion block with a Boolean representing success/failure of the operation.
    func flagSequence(sequence: VSequence, completion: ((Bool) -> ())? ) {
        let flag = SequenceFlagOperation(sequenceID: sequence.remoteId)
        let confirm = ConfirmDestructiveActionOperation(
            actionTitle: NSLocalizedString("Report/Flag", comment: ""),
            originViewController: originViewController,
            dependencyManager: dependencyManager
        )
        
        confirm.before(flag)
        confirm.queue()
        flag.queue() { (results, error, cancelled) in
            guard !flag.cancelled else {
                return
            }
            completion?( error == nil && !cancelled )
        }
    }
    
    // MARK: - Block

    /// Presents an Alert Controller to confirm blocking of a user. Upon
    /// confirmation, blocks the user and calls the completion block with a
    /// Boolean representing success/failure of the operation.
    func blockUser(user: VUser, completion: ((Bool) -> ())? ) {
        // BlockUserOperation is not supported in 5.0
    }
    
    // MARK: - Delete
    
    /// Presents an Alert Controller to confirm deletion of a sequence. Upon confirmation, deletes the
    /// sequence and calls the completion block with a Boolean representing success/failure of the operation.
    func deleteSequence(sequence: VSequence, completion: ((Bool) -> ())? ) {
        let delete = SequenceDeleteOperation(sequenceID: sequence.remoteId)
        let confirm = ConfirmDestructiveActionOperation(
            actionTitle: NSLocalizedString("DeleteButton", comment: ""),
            originViewController: originViewController,
            dependencyManager: dependencyManager
        )
        
        confirm.before(delete)
        confirm.queue()
        delete.queue() { (results, error, cancelled) in
            guard !delete.cancelled else {
                return
            }
            completion?( error == nil && !cancelled )
        }
    }
    
    // MARK: - Like
    
    func likeSequence(sequence: VSequence, triggeringView: UIView, completion: ((Bool) -> Void)?) {
        SequenceLikeToggleOperation(sequenceObjectId: sequence.objectID).queue() { results, error, cancelled in
            
            self.dependencyManager.coachmarkManager?.triggerSpecificCoachmarkWithIdentifier(
                VLikeButtonCoachmarkIdentifier,
                inViewController: self.originViewController,
                atLocation: triggeringView.convertRect(
                    triggeringView.bounds,
                    toView: self.originViewController.view
                )
            )
            
            completion?( error == nil && !cancelled )
        }
    }
    
    // MARK: - Repost
    
    func repostSequence(sequence: VSequence) {
        repostSequence(sequence, completion: nil)
    }
    
    func repostSequence(sequence: VSequence, completion: ((Bool) -> Void)?) {
        SequenceRepostOperation(sequenceID: sequence.remoteId).queue { results, error, cancelled in
            completion?( error == nil && !cancelled )
        }
    }
    
    // MARK: - Show
    
    func showLikersWithSequence(sequence: VSequence) {
        ShowLikersOperation(originViewController: originViewController,
                            dependencyManager: dependencyManager,
                            sequence: sequence).queue()
    }
    
    func showRepostersWithSequence(sequence: VSequence) {
        ShowRepostersOperation(originViewController: originViewController,
                                dependencyManager: dependencyManager,
                                sequence: sequence).queue()
    }
    
    func showMemersWithSequence(sequence: VSequence) {
        ShowMemersOperation(originViewController: originViewController,
                            dependencyManager: dependencyManager,
                            sequence: sequence).queue()
    }

    // MARK: - Private Helpers
    
    private func setupActionSheetViewController(actionSheetViewController: VActionSheetViewController, sequence: VSequence, streamId: String?) {
        var actionItems: [VActionItem] = []
        
        actionItems.append(userActionItem(forSequence: sequence))
        
        actionItems.append(descriptionActionItem(forSequence: sequence))
        
        if sequence.permissions.canMeme {
            actionItems.append(memeActionItem(forSequence: sequence))
        }
        
        if sequence.permissions.canRepost {
            actionItems.append(repostActionItem(forSequence: sequence, loadingBlock: { item in
                actionSheetViewController.setLoading(true, forItem: item)
            }))
        }
        
        actionItems.append(shareActionItem(forSequence: sequence, withStreamId: streamId ?? ""))
        
        if sequence.permissions.canDelete {
            actionItems.append(deleteActionItem(forSequence: sequence))
        }
        
        if sequence.permissions.canFlagSequence {
            actionItems.append(flagActionItem(forSequence: sequence))
        }
        
        if !sequence.user.isCurrentUser {
            actionItems.append(blockUserActionItem(forSequence: sequence))
        }
        
        if AgeGate.isAnonymousUser() {
            actionItems = AgeGate.filterMoreButtonItems(actionItems)
        }
        
        actionSheetViewController.addActionItems(actionItems)
    }
    
    private func flagActionItem(forSequence sequence: VSequence) -> VActionItem {
        let flagItem = VActionItem.defaultActionItemWithTitle(NSLocalizedString("Report/Flag", comment: ""),
            actionIcon: UIImage(named: "icon_flag"),
            detailText: "")
        flagItem.selectionHandler = { item in
            self.originViewController.dismissViewControllerAnimated(true) {
                self.flagSequence(sequence) { success in
                    if success {
                        self.originViewController.v_showFlaggedContentAlert() { success in
                            self.delegate?.sequenceActionControllerDidFlagSequence?(sequence)
                        }
                    }
                }
            }
        }
        return flagItem
    }
    
    private func blockUserActionItem(forSequence sequence: VSequence) -> VActionItem {
        let title = sequence.user.isBlockedByMainUser?.boolValue ?? false ? NSLocalizedString("UnblockUser", comment: "") : NSLocalizedString("BlockUser", comment: "")
        let blockItem = VActionItem.defaultActionItemWithTitle(title,
            actionIcon: UIImage(named: "action_sheet_block"),
            detailText: "")
        blockItem.selectionHandler = { item in
            self.originViewController.dismissViewControllerAnimated(true) {
                self.blockUser(sequence.user) { success in
                    self.delegate?.sequenceActionControllerDidBlockUser?(sequence.user)
                }
            }
        }
        return blockItem
    }
    
    private func deleteActionItem(forSequence sequence: VSequence) -> VActionItem {
        let deleteItem = VActionItem.defaultActionItemWithTitle(NSLocalizedString("Delete", comment: ""),
            actionIcon: UIImage(named: "delete-icon"),
            detailText: "")
        deleteItem.selectionHandler = { item in
            self.originViewController.dismissViewControllerAnimated(true) {
                self.deleteSequence(sequence) { success in
                    if success {
                        self.delegate?.sequenceActionControllerDidDeleteSequence?(sequence)
                    }
                }
            }
        }
        return deleteItem
    }
    
    private func shareActionItem(forSequence sequence: VSequence, withStreamId streamId: String) -> VActionItem {
        let shareItem = VActionItem.defaultActionItemWithTitle(NSLocalizedString("Share", comment: ""),
            actionIcon: UIImage(named: "icon_share"),
            detailText: "")
        let shareHandler: (VActionItem)->() = { item in
            self.originViewController.dismissViewControllerAnimated(true, completion: {
                self.shareSequence(sequence,
                    streamID: streamId,
                    completion: nil)
            })
        }
        
        shareItem.selectionHandler = shareHandler
        shareItem.detailSelectionHandler = shareHandler
        
        return shareItem
    }
    
    private func repostActionItem(forSequence sequence: VSequence, loadingBlock: (VActionItem) -> () ) -> VActionItem {
        let hasReposted = sequence.hasReposted.boolValue
        let localizedRepostRepostedText = hasReposted ? NSLocalizedString("Reposted", comment: "") : NSLocalizedString("Repost", comment: "")
        
        let repostItem = VActionItem.defaultActionItemWithTitle(localizedRepostRepostedText,
            actionIcon: UIImage(named: "icon_repost"),
            detailText: "\(sequence.repostCount)",
            enabled: !hasReposted)
        
        repostItem.selectionHandler = { item in
            if !hasReposted {
                loadingBlock(item)
                self.repostSequence(sequence) { didSucceed in
                    if didSucceed {
                        sequence.hasReposted = 1
                    }
                    self.originViewController.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
        
        repostItem.detailSelectionHandler = { item in
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectShowReposters)
            self.originViewController.dismissViewControllerAnimated(true) {
                self.showRepostersWithSequence(sequence)
            }
        }
        
        return repostItem
    }
    
    private func descriptionActionItem(forSequence sequence: VSequence) -> VActionItem {
        let descriptionItem = VActionItem.descriptionActionItemWithText(sequence.name ?? "") { hashtag in
            let vc: VHashtagStreamCollectionViewController = self.dependencyManager.hashtagStreamWithHashtag(hashtag)
            self.originViewController.dismissViewControllerAnimated(true) {
                self.originViewController.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return descriptionItem
    }
    
    private func userActionItem(forSequence sequence: VSequence) -> VActionItem {
        let name = sequence.user.name ?? ""
        let userItem = VActionItem.userActionItemUserWithTitle(name, user: sequence.user, detailText: "")
        userItem.selectionHandler = { item in
            self.originViewController.dismissViewControllerAnimated(true) {
                self.showProfileWithRemoteId(sequence.user.remoteId.integerValue)
            }
        }
        return userItem
    }
    
    private func memeActionItem(forSequence sequence: VSequence) -> VActionItem {
        let memeItem = VActionItem.defaultActionItemWithTitle(NSLocalizedString("Create a meme", comment: ""),
            actionIcon: UIImage(named: "D_memeIcon"),
            detailText: "\(sequence.memeCount)")
        
        memeItem.selectionHandler = { item in
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectRemix)
            
            self.originViewController.dismissViewControllerAnimated(true) {
                self.showRemixWithSequence(sequence)
            }
        }
        
        memeItem.detailSelectionHandler = { item in
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectShowRemixes)
            
            self.originViewController.dismissViewControllerAnimated(true) {
                self.showMemersWithSequence(sequence)
            }
        }
        return memeItem
    }
}
