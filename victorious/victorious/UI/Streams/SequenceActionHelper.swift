//
//  SequenceActionHelper.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

@objc class SequenceActionHelper: NSObject {
    
    var dependencyManager: VDependencyManager
    var originViewController: UIViewController
    var sequenceActionController: VSequenceActionController
    
    
    init(dependencyManager: VDependencyManager, originViewController: UIViewController, sequenceActionController: VSequenceActionController) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.sequenceActionController = sequenceActionController
        super.init()
    }
    
    func moreButtonAction(sequence: VSequence, completion: ()->()) {
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
        actionItems.append(shareItem(sequence))
        
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
        originViewController.presentViewController(actionSheetViewController, animated: true, completion: nil)
        
    }
    
    private func flagItem(sequence: VSequence) -> VActionItem {
        
        let flagItem = VActionItem.defaultActionItemWithTitle(NSLocalizedString("Report/Flag", comment: ""),
                                                                actionIcon: UIImage(named: "icon_flag"),
                                                                detailText: "")
        flagItem.selectionHandler = { item in
            self.originViewController.dismissViewControllerAnimated(true, completion: {
                self.sequenceActionController.flagSheetFromViewController(self.originViewController, sequence: sequence, completion: { success in
//                    self.originViewController.contentViewPresenterDidFlagContent(nil)
                })
            })
        }
        return flagItem
        
    }
    
    private func deleteItem(sequence: VSequence) -> VActionItem {
        
        let deleteItem = VActionItem.defaultActionItemWithTitle(NSLocalizedString("Delete", comment: ""),
                                                                actionIcon: UIImage(named: "delete-icon"),
                                                                detailText: "")
        deleteItem.selectionHandler = { item in
            self.originViewController.dismissViewControllerAnimated(true, completion: {
                let alertController = UIAlertController(title: NSLocalizedString("AreYouSureYouWantToDelete", comment: ""),
                    message: nil,
                    preferredStyle: UIAlertControllerStyle.ActionSheet)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("CancelButton", comment: ""),
                    style: UIAlertActionStyle.Cancel,
                    handler: nil))
                alertController.addAction(UIAlertAction(title: NSLocalizedString("DeleteButton", comment: ""),
                    style: UIAlertActionStyle.Destructive,
                    handler: { action in
                        let deleteOperation = DeleteSequenceOperation(sequenceID: sequence.remoteId)
                        deleteOperation.queueOn(deleteOperation.defaultQueue, completionBlock: { results, error in
                            VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidDeletePost)
                            //                            self.originViewController.contentViewPresenterDidDeleteContent(nil)
                        })
                }))
            })
        }
        return deleteItem
        
    }
    
    private func shareItem(sequence: VSequence) -> VActionItem {
        
        let shareItem = VActionItem.defaultActionItemWithTitle(NSLocalizedString("Share", comment: ""),
                                                               actionIcon: UIImage(named: "icon_share"),
                                                               detailText: "")
        let shareHandler: (VActionItem)->() = { item in
            self.originViewController.dismissViewControllerAnimated(true, completion: {
                self.sequenceActionController.shareFromViewController(self.originViewController,
                    sequence: sequence,
                    node: sequence.firstNode(),
                    streamID: sequence.remoteId, //self.viewModel.streamId -> might be causing an issue here
                    completion: nil)
            })
        }
        
        shareItem.selectionHandler = shareHandler
        shareItem.detailSelectionHandler = shareHandler
        
        return shareItem
        
    }
    
    private func repostItem(sequence: VSequence, loadingBlock: (VActionItem)->() ) -> VActionItem {
        
        let localizedRepostRepostedText = sequence.hasReposted.boolValue ? NSLocalizedString("Resposted", comment: "") : NSLocalizedString("Repost", comment: "")
        let hasReposted = sequence.hasReposted.boolValue
        
        let repostItem = VActionItem.defaultActionItemWithTitle(localizedRepostRepostedText,
                                                                actionIcon: UIImage(named: "icon_repost"),
                                                                detailText: "\(sequence.repostCount)",
                                                                enabled: !hasReposted)
        repostItem.selectionHandler = { item in
            if (!hasReposted) {
                loadingBlock(item)
                self.sequenceActionController.repostActionFromViewController(self.originViewController, node: sequence.firstNode(), completion: { didSucceed in
                    if (didSucceed) {
                        sequence.hasReposted = 1
                    }
                    self.originViewController.dismissViewControllerAnimated(true, completion: nil)
                })
            }
        }
        
        repostItem.detailSelectionHandler = { item in
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectShowReposters)
            self.originViewController.dismissViewControllerAnimated(true, completion: {
                self.sequenceActionController.showRepostersFromViewController(self.originViewController, sequence: sequence)
            })
        }
        
        return repostItem
        
    }
    
    private func descriptionItem(sequence: VSequence) -> VActionItem {
        
        let descriptionItem = VActionItem.descriptionActionItemWithText(sequence.name ?? "", hashTagSelectionHandler: { hashtag in
            let vc: VHashtagStreamCollectionViewController = self.dependencyManager.hashtagStreamWithHashtag(hashtag)
            self.originViewController.dismissViewControllerAnimated(true, completion: {
                self.originViewController.navigationController?.pushViewController(vc, animated: true)
            })
        })
        return descriptionItem
        
    }
    
    private func userItem(sequence: VSequence) -> VActionItem {
        
        let userItem = VActionItem.userActionItemUserWithTitle(sequence.user.name, user: sequence.user, detailText: "")
        userItem.selectionHandler = { item in
            self.originViewController.dismissViewControllerAnimated(true, completion: {
                self.sequenceActionController.showPosterProfileFromViewController(self.originViewController, sequence: sequence)
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
                                self.sequenceActionController.showRemixOnViewController(self.originViewController,
                                    withSequence: sequence,
                                    andDependencyManager: self.dependencyManager,
                                    preloadedImage: nil,
                                    defaultVideoEdit: VDefaultVideoEdit.Snapshot,
                                    completion: nil)
            },
                             dismissCompletionBlock: {
                                self.sequenceActionController.showMemersOnNavigationController(self.originViewController.navigationController, sequence: sequence, andDependencyManager: self.dependencyManager)
        })
        return memeItem
    }
    
    private func gifItem(sequence: VSequence) -> VActionItem {
        
        let gifItem = VActionItem.defaultActionItemWithTitle(NSLocalizedString("Create a GIF", comment: ""),
                                                             actionIcon: UIImage(named: "D_gifIcon"),
                                                             detailText: "\(sequence.gifCount)")
        
        setupRemixActionItem(gifItem,
                             block: {
                                self.sequenceActionController.showRemixOnViewController(self.originViewController,
                                    withSequence: sequence,
                                    andDependencyManager: self.dependencyManager,
                                    preloadedImage: nil,
                                    defaultVideoEdit: VDefaultVideoEdit.GIF,
                                    completion: nil)
            },
                             dismissCompletionBlock: {
                                self.sequenceActionController.showMemersOnNavigationController(self.originViewController.navigationController, sequence: sequence, andDependencyManager: self.dependencyManager)
        })
        return gifItem
        
    }
    
    private func setupRemixActionItem(remixItem: VActionItem, block: ()->(), dismissCompletionBlock: ()->()) {
        
        remixItem.selectionHandler = { item in
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectRemix)
            
            self.originViewController.dismissViewControllerAnimated(true, completion: {
                block()
            })
        }
        
        remixItem.detailSelectionHandler = { item in
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectShowRemixes)
            
            self.originViewController.dismissViewControllerAnimated(true, completion: {
                dismissCompletionBlock()
            })
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
    
    func flagSequence( sequence: VSequence, fromViewController viewController: UIViewController, completion:((Bool) -> Void)? ) {
        
        FlagSequenceOperation(sequenceID: sequence.remoteId ).queue() { (results, error) in
           
            if let error = error {
                let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
                VTrackingManager.sharedInstance().trackEvent( VTrackingEventFlagPostDidFail, parameters: params )
                
                if error.code == Int(kVCommentAlreadyFlaggedError) {
                    viewController.v_showFlaggedConversationAlert(completion: completion)
                } else {
                    viewController.v_showErrorDefaultError()
                }
           
            } else {
                VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidFlagPost )
                viewController.v_showFlaggedConversationAlert(completion: completion)
            }
        }
    }
}
