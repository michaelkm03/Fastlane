//
//  VSequenceActionController+Helper.swift
//  victorious
//
//  Created by Vincent Ho on 2/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VSequenceActionController {
    
    func moreButtonAction(withSequence sequence: VSequence, streamId: String?, completion: (()->())? ) {
        let actionSheetViewController = VActionSheetViewController()
        actionSheetViewController.dependencyManager = dependencyManager
        VActionSheetTransitioningDelegate.addNewTransitioningDelegateToActionSheetController(actionSheetViewController)
        
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectMoreActions)
        
        var actionItems: [VActionItem] = []
        
        // User item
        actionItems.append(userItem(sequence))
        
        // Description item
        actionItems.append(descriptionItem(sequence))
        
        if sequence.permissions.canGIF {
            actionItems.append(gifItem(sequence))
        }
        
        if sequence.permissions.canMeme {
            actionItems.append(memeItem(sequence))
        }
        
        if sequence.permissions.canRepost {
            actionItems.append(repostItem(sequence, loadingBlock: { item in
                actionSheetViewController.setLoading(true, forItem: item)
            }))
        }
        
        // Share Item
        actionItems.append(shareItem(sequence, withStreamId: streamId ?? ""))
        
        if sequence.permissions.canDelete {
            actionItems.append(deleteItem(sequence))
        }
        
        if sequence.permissions.canFlagSequence {
            actionItems.append(flagItem(sequence))
        }
        
        if AgeGate.isAnonymousUser() {
            actionItems = AgeGate.filterMoreButtonItems(actionItems)
        }
        
        actionSheetViewController.addActionItems(actionItems)
        originViewController.presentViewController(actionSheetViewController, animated: true) {
            completion?()
        }
    }
    
    func flag(sequence: VSequence, completion: (Bool)->()) {
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectMoreActions)
        
        
        let flagBlock = {
            FlagSequenceOperation(sequenceID: sequence.remoteId ).queue() { (results, error) in
                
                if let error = error {
                    let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
                    VTrackingManager.sharedInstance().trackEvent( VTrackingEventFlagPostDidFail, parameters: params )
                    
                    if error.code == Int(kVCommentAlreadyFlaggedError) {
                        self.originViewController.v_showFlaggedConversationAlert(completion: completion)
                    } else {
                        self.originViewController.v_showErrorDefaultError()
                    }
                    
                } else {
                    VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidFlagPost )
                    self.originViewController.v_showFlaggedConversationAlert(completion: completion)
                }
            }
        }
        
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Report/Flag", comment: ""),
            style: UIAlertActionStyle.Default,
            handler: { action in
                flagBlock()
            }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"),
            style: UIAlertActionStyle.Default,
            handler:nil))
        originViewController.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    private func flagItem(sequence: VSequence) -> VActionItem {
        
        let flagItem = VActionItem.defaultActionItemWithTitle(NSLocalizedString("Report/Flag", comment: ""),
                                                              actionIcon: UIImage(named: "icon_flag"),
                                                              detailText: "")
        flagItem.selectionHandler = { item in
            self.originViewController.dismissViewControllerAnimated(true) {
                self.flag(sequence) { success in
                    if self.shouldDismissOnDelete {
                        self.originViewController.presentingViewController?.dismissViewControllerAnimated(true) {
                            if self.delegate.respondsToSelector("contentViewDidFlagContent:") {
                                self.delegate.performSelector("contentViewDidFlagContent:", withObject: nil)
                            }
                        }
                    }
                    else {
                        if self.delegate.respondsToSelector("contentViewDidFlagContent:") {
                            self.delegate.performSelector("contentViewDidFlagContent:", withObject: nil)
                        }                    }


                }
            }
        }
        return flagItem
        
    }
    
    func delete(sequence: VSequence, completion: (Bool)->()) {
        let deleteBlock = {
            let deleteOperation = DeleteSequenceOperation(sequenceID: sequence.remoteId)
            deleteOperation.queueOn(deleteOperation.defaultQueue) { results, error in
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidDeletePost)
                if let error = error {
                    print ("Error: \(error.code)")
                    completion(false)
                }
                else {
                    completion(true)
                }
            }
        }
        
        let alertController = UIAlertController(title: NSLocalizedString("AreYouSureYouWantToDelete", comment: ""),
                                                message: nil,
                                                preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("CancelButton", comment: ""),
            style: UIAlertActionStyle.Cancel,
            handler: nil))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("DeleteButton", comment: ""),
                                                style: UIAlertActionStyle.Destructive) { action in
                             
            if self.shouldDismissOnDelete {
                self.originViewController.presentingViewController?.dismissViewControllerAnimated(true) {
                    deleteBlock()
                }
            }
            else {
                deleteBlock()
            }

        })
        
        self.originViewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func deleteItem(sequence: VSequence) -> VActionItem {
        
        let deleteItem = VActionItem.defaultActionItemWithTitle(NSLocalizedString("Delete", comment: ""),
                                                                actionIcon: UIImage(named: "delete-icon"),
                                                                detailText: "")
        deleteItem.selectionHandler = { item in
            self.originViewController.dismissViewControllerAnimated(true) {
                self.delete(sequence) { success in
                    if self.delegate.respondsToSelector("contentViewDidDeleteContent:") {
                        self.delegate.performSelector("contentViewDidDeleteContent:", withObject: nil)
                    }
                }
            }
        }
        return deleteItem
        
    }
    
    private func shareItem(sequence: VSequence, withStreamId streamId: String) -> VActionItem {
        
        let shareItem = VActionItem.defaultActionItemWithTitle(NSLocalizedString("Share", comment: ""),
                                                               actionIcon: UIImage(named: "icon_share"),
                                                               detailText: "")
        let shareHandler: (VActionItem)->() = { item in
            self.originViewController.dismissViewControllerAnimated(true, completion: {
                self.shareWithSequence(sequence,
                    node: sequence.firstNode(),
                    streamID: streamId, //self.viewModel.streamId -> might be causing an issue here
                    completion: nil)
            })
        }
        
        shareItem.selectionHandler = shareHandler
        shareItem.detailSelectionHandler = shareHandler
        
        return shareItem
        
    }
    
    private func repostItem(sequence: VSequence, loadingBlock: (VActionItem)->() ) -> VActionItem {
        
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
    
    private func descriptionItem(sequence: VSequence) -> VActionItem {
        
        let descriptionItem = VActionItem.descriptionActionItemWithText(sequence.name ?? "", hashTagSelectionHandler: { hashtag in
            let vc: VHashtagStreamCollectionViewController = self.dependencyManager.hashtagStreamWithHashtag(hashtag)
            self.originViewController.dismissViewControllerAnimated(true) {
                self.originViewController.navigationController?.pushViewController(vc, animated: true)
            }
        })
        return descriptionItem
        
    }
    
    private func userItem(sequence: VSequence) -> VActionItem {
        
        let userItem = VActionItem.userActionItemUserWithTitle(sequence.user.name, user: sequence.user, detailText: "")
        userItem.selectionHandler = { item in
            self.originViewController.dismissViewControllerAnimated(true, completion: {
                self.showPosterProfileWithSequence(sequence)
            })
        }
        return userItem
        
    }
    
    private func memeItem(sequence: VSequence) -> VActionItem {
        
        let memeItem = VActionItem.defaultActionItemWithTitle(NSLocalizedString("Create a meme", comment: ""),
                                                              actionIcon: UIImage(named: "D_gifIcon"),
                                                              detailText: "\(sequence.memeCount)")
        
        setupRemixActionItem(memeItem,
                             block: {
                                self.showRemixWithSequence(sequence,
                                    preloadedImage: nil,
                                    defaultVideoEdit: VDefaultVideoEdit.Snapshot,
                                    completion: nil)
            },
                             dismissCompletionBlock: {
                                self.showMemersOnNavigationController(self.originViewController.navigationController, sequence: sequence)
        })
        return memeItem
    }
    
    private func gifItem(sequence: VSequence) -> VActionItem {
        
        let gifItem = VActionItem.defaultActionItemWithTitle(NSLocalizedString("Create a GIF", comment: ""),
                                                             actionIcon: UIImage(named: "D_gifIcon"),
                                                             detailText: "\(sequence.gifCount)")
        
        setupRemixActionItem(gifItem,
                             block: {
                                self.showRemixWithSequence(sequence,
                                    preloadedImage: nil,
                                    defaultVideoEdit: VDefaultVideoEdit.GIF,
                                    completion: nil)
            },
                             dismissCompletionBlock: {
                                self.showMemersOnNavigationController(self.originViewController.navigationController, sequence: sequence)
        })
        return gifItem
        
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
    
    func likeSequence(sequence: VSequence, triggeringView: UIView, completion: ((Bool) -> Void)?) {
        
        if sequence.isLikedByMainUser.boolValue {
            UnlikeSequenceOperation( sequenceID: sequence.remoteId ).queue() { error in
                completion?( error == nil )
            }
            
        } else {
            LikeSequenceOperation( sequenceID: sequence.remoteId ).queue() { error in
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
    
    func repostNode( node: VNode, completion: ((Bool) -> Void)?) {
        RepostSequenceOperation(nodeID: node.remoteId.integerValue ).queue { error in
            
            if let error = error {
                let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventRepostDidFail, parameters:params )
                
            } else {
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidRepost)
            }
            completion?( error == nil )
        }
    }

}