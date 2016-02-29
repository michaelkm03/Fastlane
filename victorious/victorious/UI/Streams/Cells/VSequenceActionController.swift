//
//  VSequenceActionController+Actions.swift
//  victorious
//
//  Created by Vincent Ho on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc class VSequenceActionController : NSObject {
    
    let dependencyManager: VDependencyManager
    let originViewController: UIViewController
    private var remixPresenter: VRemixPresenter?
    
    private(set) weak var delegate: VSequenceActionControllerDelegate?
    
    //  MARK: - Initializer
    
    /// Sets up the SequenceActionController with the dependency manager and the view controller on
    /// which it should be presented.
    ///
    /// - parameter dependencyManager: The dependency manager. Should not be nil.
    /// - parameter originViewController: The view controller on which the Action Sheet should displayed.
    /// Should not be nil.
    /// - parameter delegate: The delegate conforming to protocol "VSequenceActionControllerDelegate" 
    /// to handle the deletion/flagging callbacks
    
    init(dependencyManager: VDependencyManager, originViewController: UIViewController, delegate: VSequenceActionControllerDelegate) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.delegate = delegate
        super.init()
    }
    
    /// Presents a VActionSheetViewController set up with options based off of the VSequence object provided.
    ///
    /// - parameter sequence: The sequence whose available actions we want to display on the action sheet.
    /// Should not be nil.
    /// - parameter streamId: The streamID.
    /// - parameter completion: Completion block to be called after the action sheet has been presented.
    
    func showMoreWithSequence(sequence: VSequence, streamId: String?, completion: (()->())? ) {
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectMoreActions)
        
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
        let mediaLinkViewController = VAbstractMediaLinkViewController.newWithMediaUrl(mediaUrl, andMediaLinkType: linkType)
        originViewController.presentViewController(mediaLinkViewController, animated: true, completion: nil)
    }
    
    // MARK: - Remix
    
    func showRemixWithSequence(sequence: VSequence) {
        assert(!sequence.isPoll(), "You cannot remix polls.")
        
        remixPresenter = VRemixPresenter(dependencymanager: dependencyManager, sequenceToRemix: sequence)
        remixPresenter?.presentOnViewController(originViewController)
    }
    
    // MARK: - User
    
    func showProfileWithRemoteId(userId: Int) {
        ShowProfileOperation(originViewController: originViewController, dependencyManager: dependencyManager, userId: userId).queue()
    }
    
    // MARK: - Share
    
    func shareSequence(sequence: VSequence, node: VNode, streamID: String?, completion: (()->())? ) {
        ShowShareSequenceOperation(originViewController: originViewController,
                                   dependencyManager: dependencyManager,
                                   sequence: sequence,
                                   node: node,
                                   streamID: streamID).queue() {
                                       completion?()
        }
    }
    
    // MARK: - Comments
    
    func showCommentsWithSequence(sequence: VSequence) {
        if let commentsViewController: CommentsViewController = dependencyManager.commentsViewController(sequence) {
            originViewController.navigationController?.pushViewController(commentsViewController, animated: true)
        }
    }
    
    // MARK: - Flag
    
    /// Presents an Alert Controller to confirm flagging of a sequence. Upon confirmation, flags the
    /// sequence and calls the completion block with a Boolean representing success/failure of the operation.
    func flagSequence(sequence: VSequence, completion: ((Bool)->())? ) {
        
        let flagAlertOperation: FlagSequenceAlertOperation =
            FlagSequenceAlertOperation(originViewController: originViewController,
                                         dependencyManager: dependencyManager,
                                         sequence: sequence)
        flagAlertOperation.queue() {
            if flagAlertOperation.didFlagSequence {
                self.originViewController.v_showFlaggedContentAlert(completion: completion)
            }
            else if flagAlertOperation.didCancelFlag {
                completion?(false)
            }
            else if flagAlertOperation.errorCode == Int(kVSequenceAlreadyFlagged) {
                self.originViewController.v_showFlaggedContentAlert(completion: completion)
            }
            else {
                self.originViewController.v_showErrorDefaultError()
                completion?(false)
            }
        }

    }
    
    // MARK: - Block

    /// Presents an Alert Controller to confirm blocking of a user. Upon
    /// confirmation, blocks the user and calls the completion block with a
    /// Boolean representing success/failure of the operation.
    ///
    /// - parameter sequence:           The user we want to block. Should not
    /// be nil.
    /// - parameter completion:         A completion block takes in a Boolean
    /// argument representing success/failure.
    
    func blockUser(user: VUser, completion: ((Bool)->())? ) {
        
        let blockUserOperation: ToggleBlockUserOperation =
        ToggleBlockUserOperation(originViewController: originViewController,
            dependencyManager: dependencyManager,
            user: user,
            presentationCompletion: nil)
        
        blockUserOperation.queue() { results, error in
            
            if error != nil {
                self.originViewController.v_showErrorDefaultError()
                completion?(false)
            } else if !blockUserOperation.isUnblockOperation {
                self.originViewController.v_showFlaggedUserAlert(completion: completion)
            }
        }
    }
    
    // MARK: - Delete
    
    /// Presents an Alert Controller to confirm deletion of a sequence. Upon confirmation, deletes the
    /// sequence and calls the completion block with a Boolean representing success/failure of the operation.
    func deleteSequence(sequence: VSequence, completion: ((Bool)->())? ) {
        let deleteAlertOperation: DeleteSequenceAlertOperation =
            DeleteSequenceAlertOperation(originViewController: originViewController,
                                         dependencyManager: dependencyManager,
                                         sequence: sequence)
        deleteAlertOperation.queue() {
            completion?(deleteAlertOperation.didDeleteSequence)
        }
    }
    
    // MARK: - Like
    func likeSequence(sequence: VSequence, triggeringView: UIView, completion: ((Bool) -> Void)?) {
        ToggleLikeSequenceOperation(sequenceObjectId: sequence.objectID).queue() { results, error in
            if sequence.isLikedByMainUser.boolValue {
                completion?( error == nil )
            }
            else {
                VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidSelectLike )
                self.dependencyManager.coachmarkManager().triggerSpecificCoachmarkWithIdentifier(
                    VLikeButtonCoachmarkIdentifier,
                    inViewController:self.originViewController,
                    atLocation:triggeringView.convertRect(
                        triggeringView.bounds,
                        toView:self.originViewController.view
                    )
                )
                completion?( error == nil )
            }
        }
    }
    
    // MARK: - Repost
    
    func repostNode(node: VNode) {
        repostNode(node, completion: nil)
    }
    
    func repostNode(node: VNode, completion: ((Bool) -> Void)?) {
        RepostSequenceOperation(nodeID: node.remoteId.integerValue ).queue { results, error in
            if let error = error {
                let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventRepostDidFail, parameters:params )
                
            } else {
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidRepost)
            }
            completion?( error == nil )
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
        
        actionItems.append(blockUserActionItem(forSequence: sequence))
        
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
            self.originViewController.dismissViewControllerAnimated(true, completion: {
                self.flagSequence(sequence, completion: { success in
                    if success {
                        self.delegate?.sequenceActionControllerDidFlagContent?()
                    }
                })
            })
        }
        return flagItem
    }
    
    private func blockUserActionItem(forSequence sequence: VSequence) -> VActionItem {
        let title = sequence.user.isBlockedByMainUser == true ? NSLocalizedString("UnblockUser", comment: "") : NSLocalizedString("BlockUser", comment: "")
        let blockItem = VActionItem.defaultActionItemWithTitle(title,
            actionIcon: UIImage(named: "action_sheet_block"),
            detailText: "")
        blockItem.selectionHandler = { item in
            self.originViewController.dismissViewControllerAnimated(true, completion: {
                self.blockUser(sequence.user, completion: { success in
                    self.delegate?.sequenceActionControllerDidBlockUser?()
                })
            })
        }
        return blockItem
    }
    
    private func deleteActionItem(forSequence sequence: VSequence) -> VActionItem {
        let deleteItem = VActionItem.defaultActionItemWithTitle(NSLocalizedString("Delete", comment: ""),
            actionIcon: UIImage(named: "delete-icon"),
            detailText: "")
        deleteItem.selectionHandler = { item in
            self.originViewController.dismissViewControllerAnimated(true, completion: {
                self.deleteSequence(sequence, completion: { success in
                    if success {
                        self.delegate?.sequenceActionControllerDidDeleteContent?()
                    }
                })
            })
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
                    node: sequence.firstNode(),
                    streamID: streamId,
                    completion: nil)
            })
        }
        
        shareItem.selectionHandler = shareHandler
        shareItem.detailSelectionHandler = shareHandler
        
        return shareItem
    }
    
    private func repostActionItem(forSequence sequence: VSequence, loadingBlock: (VActionItem)->() ) -> VActionItem {
        let hasReposted = sequence.hasReposted.boolValue
        let localizedRepostRepostedText = hasReposted ? NSLocalizedString("Resposted", comment: "") : NSLocalizedString("Repost", comment: "")
        
        let repostItem = VActionItem.defaultActionItemWithTitle(localizedRepostRepostedText,
            actionIcon: UIImage(named: "icon_repost"),
            detailText: "\(sequence.repostCount)",
            enabled: !hasReposted)
        
        repostItem.selectionHandler = { item in
            if (!hasReposted) {
                loadingBlock(item)
                self.repostNode(sequence.firstNode())  { didSucceed in
                    if (didSucceed) {
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
        let descriptionItem = VActionItem.descriptionActionItemWithText(sequence.name ?? "", hashTagSelectionHandler: { hashtag in
            let vc: VHashtagStreamCollectionViewController = self.dependencyManager.hashtagStreamWithHashtag(hashtag)
            self.originViewController.dismissViewControllerAnimated(true) {
                self.originViewController.navigationController?.pushViewController(vc, animated: true)
            }
        })
        return descriptionItem
    }
    
    private func userActionItem(forSequence sequence: VSequence) -> VActionItem {
        let userItem = VActionItem.userActionItemUserWithTitle(sequence.user.name, user: sequence.user, detailText: "")
        userItem.selectionHandler = { item in
            self.originViewController.dismissViewControllerAnimated(true, completion: {
                self.showProfileWithRemoteId(sequence.user.remoteId.integerValue)
            })
        }
        
        return userItem
    }
    
    private func memeActionItem(forSequence sequence: VSequence) -> VActionItem {
        let memeItem = VActionItem.defaultActionItemWithTitle(NSLocalizedString("Create a meme", comment: ""),
            actionIcon: UIImage(named: "D_memeIcon"),
            detailText: "\(sequence.memeCount)")
        
        setupRemixActionItem(memeItem,
            block: {
                self.showRemixWithSequence(sequence)
            },
            dismissCompletionBlock: {
                self.showMemersWithSequence(sequence)
        })
        
        return memeItem
    }
    
    private func setupRemixActionItem(remixItem: VActionItem, block: ()->(), dismissCompletionBlock: ()->()) {
        remixItem.selectionHandler = { item in
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectRemix)
            
            self.originViewController.dismissViewControllerAnimated(true) {
                block()
            }
        }
        
        remixItem.detailSelectionHandler = { item in
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectShowRemixes)
            
            self.originViewController.dismissViewControllerAnimated(true) {
                dismissCompletionBlock()
            }
        }
    }
    
}
