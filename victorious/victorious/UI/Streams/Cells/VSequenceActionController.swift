//
//  VSequenceActionController+Actions.swift
//  victorious
//
//  Created by Vincent Ho on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc class VSequenceActionController : NSObject {
    
    private(set) var dependencyManager: VDependencyManager
    private(set) var originViewController: UIViewController
    private(set) var delegate: VSequenceActionControllerDelegate
    private(set) var shouldDismissOnDelete: Bool
    
    //   MARK: - Initializer
    
    ///
    ///  Sets up the SequenceActionController with the dependency manager and the view controller that it should be presented on
    ///
    ///  - parameter shouldDismissOnDelete:      Should originViewController be dismissed if the sequence is flagged/deleted
    ///
    
    init(dependencyManager: VDependencyManager, originViewController: UIViewController, delegate: VSequenceActionControllerDelegate, shouldDismissOnDelete: Bool) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.delegate = delegate
        self.shouldDismissOnDelete = shouldDismissOnDelete
        super.init()
    }
    
    //   MARK: - Show Media
    
    func showMediaContent(url: NSURL?, mediaLinkType linkType: VCommentMediaType) {
        guard let url = url else {
            return
        }
        let mediaLinkViewController = VAbstractMediaLinkViewController.newWithMediaUrl(url, andMediaLinkType: linkType)
        originViewController.presentViewController(mediaLinkViewController, animated: true, completion: nil)
    }
    
    // MARK: - Remix
    ///
    ///  Presents remix UI on the ViewController given in the initializer with a given sequence to remix.
    ///  Will present a UIViewController for the remix UI on the passed in originViewController.
    ///
    ///  - parameter sequence:          The sequence to remix.
    ///  - parameter defaultVideoEdit:  The default video editing state.
    ///  - parameter completion:        A completion block. BOOL is YES if successful publish, NO if cancelled out.
    ///
    
    func showRemixWithSequence(sequence: VSequence?) {
        guard let sequence = sequence else {
                return
        }
        assert(!sequence.isPoll(), "You cannot remix polls.")
        
        let remixPresenter = VRemixPresenter(dependencymanager: dependencyManager, sequenceToRemix: sequence)
        remixPresenter.presentOnViewController(originViewController)
    }
    
    // MARK: - User
    
    func showProfileWithRemoteId(remoteId: Int) -> Bool {
        guard let navigationViewController = originViewController.navigationController else {
                return false
        }
        
        if let originViewControllerProfile = originViewController as? VUserProfileViewController where originViewControllerProfile.user.remoteId.integerValue == remoteId {
            return false
        }
        
        let profileViewController = dependencyManager.userProfileViewControllerWithRemoteId(remoteId)
        navigationViewController.pushViewController(profileViewController, animated: true)
        
        return true
    }
    
    // MARK: - Share
    
    func shareSequence(sequence: VSequence?, node: VNode?, streamID: String?, completion: (()->())? ) {
        guard let sequence = sequence,
            node = node else {
                return
        }
        
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectShare)
        let appInfo: VAppInfo = VAppInfo(dependencyManager: dependencyManager)
        
        let fbActivity: VFacebookActivity = VFacebookActivity()
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems:
            [
                sequence ?? NSNull(),
                shareTextForSequence(sequence),
                NSURL(string: node.shareUrlPath) ?? NSNull()
            ], applicationActivities:[fbActivity])
        
        let creatorName = appInfo.appName
        let emailSubject = String(format: NSLocalizedString("EmailShareSubjectFormat", comment: ""), creatorName)
        activityViewController.setValue(emailSubject, forKey: "subject")
        activityViewController.excludedActivityTypes = [UIActivityTypePostToFacebook]
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            
            var tracking: VTracking?
            if let streamID = streamID {
                tracking = sequence.streamItemPointer(streamID: streamID)?.tracking
            }
            else {
                tracking = sequence.streamItemPointerForStandloneStreamItem()?.tracking
            }
            assert(tracking != nil, "Cannot track 'share' event because tracking data is missing.")
            
            if completed {
                let params = [
                    VTrackingKeySequenceCategory : sequence.category ?? "",
                    VTrackingKeyShareDestination : activityType ?? "",
                    VTrackingKeyUrls : tracking?.share ?? []
                ]
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidShare, parameters: params)
            }
            else if let activityError = activityError {
                let params = [
                    VTrackingKeySequenceCategory : sequence.category ?? "",
                    VTrackingKeyShareDestination : activityType ?? "",
                    VTrackingKeyUrls : tracking?.share ?? [],
                    VTrackingKeyErrorMessage : activityError.localizedDescription
                ]
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidShare, parameters: params)
            }
            
            self.originViewController.reloadInputViews()
            completion?()
        }
        
        self.originViewController.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Comments
    
    func showCommentsWithSequence(sequence: VSequence?, withSelectedComment selectedComment: VComment?) {
        // selected comment is not used
        guard let sequence = sequence else {
            return
        }
        
        if let commentsViewController: CommentsViewController = dependencyManager.commentsViewController(sequence) {
            originViewController.navigationController?.pushViewController(commentsViewController, animated: true)
        }
    }
    
    // MARK: - Flag
    
    func flagSequence(sequence: VSequence?, completion: ((Bool)->())? ) {
        guard let sequence = sequence else {
            completion?(false)
            return
        }
        
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
    
    // MARK: - Delete
    
    func deleteSequence(sequence: VSequence?, completion: ((Bool)->())? ) {
        guard let sequence = sequence else {
            completion?(false)
            return
        }
        let deleteBlock = {
            let deleteOperation = DeleteSequenceOperation(sequenceID: sequence.remoteId)
            deleteOperation.queueOn(deleteOperation.defaultQueue) { results, error in
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidDeletePost)
                if let error = error {
                    print ("Error: \(error.code)")
                    completion?(false)
                }
                else {
                    completion?(true)
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
                deleteBlock()
            })
        
        self.originViewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Like
    
    func likeSequence(sequence: VSequence?, triggeringView: UIView?, completion: ((Bool) -> Void)?) {
        guard let sequence = sequence,
            triggeringView = triggeringView else {
                completion?(false)
                return
        }
        
        if sequence.isLikedByMainUser.boolValue {
            UnlikeSequenceOperation( sequenceID: sequence.remoteId ).queue() { error in
                completion?( error == nil )
            }
        }
        else {
            LikeSequenceOperation( sequenceID: sequence.remoteId ).queue() { results, error in
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
    
    func repostNode(node: VNode?) {
        repostNode(node, completion: nil)
    }
    
    func repostNode(node: VNode?, completion: ((Bool) -> Void)?) {
        guard let node = node else {
            completion?(false)
            return
        }
        
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
    
    // MARK: - Show
    
    /**
    *  Pushes a remixers VC on the given navigation controller for the given sequence.
    *
    *  @param sequence             A valid sequence. Can't be nil.
    */
    
    func showLikersWithSequence(sequence: VSequence?) {
        guard let sequence = sequence else {
            return
        }
        
        if let vc: VReposterTableViewController = VReposterTableViewController(sequence: sequence, dependencyManager: dependencyManager) {
            originViewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showRepostersWithSequence(sequence: VSequence?) {
        guard let sequence = sequence else {
            return
        }
        
        if let vc: VReposterTableViewController = VReposterTableViewController(sequence: sequence, dependencyManager: dependencyManager) {
            originViewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showMemersWithSequence(sequence: VSequence?) {
        guard let sequence = sequence else {
            return
        }
        
        if let memeStream = dependencyManager.memeStreamForSequence(sequence) {
            originViewController.navigationController?.pushViewController(memeStream, animated: true)
        }
        
    }
    
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

}

// MARK: - Extension

extension VSequenceActionController {
    
    enum DelegateCallback {
        case Flag
        case Delete
    }
    
    func setupActionSheetViewController(actionSheetViewController: VActionSheetViewController, sequence: VSequence, streamId: String?) {
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
        
        if AgeGate.isAnonymousUser() {
            actionItems = AgeGate.filterMoreButtonItems(actionItems)
        }
        
        actionSheetViewController.addActionItems(actionItems)
    }
    
    // MARK: Delegate Helpers
    
    private func callDelegateWith(delegateCallback: DelegateCallback) {
        switch delegateCallback {
        case DelegateCallback.Flag:
            delegate.sequenceActionControllerDidFlagContent?()
        case DelegateCallback.Delete:
            delegate.sequenceActionControllerDidDeleteContent?()
        }
    }
    
    private func dismissAndCallDelegateCallbackWith(delegateCallbackType: DelegateCallback) {
        if self.shouldDismissOnDelete {
            self.originViewController.presentingViewController?.dismissViewControllerAnimated(true) {
                self.callDelegateWith(delegateCallbackType)
            }
        }
        else {
            callDelegateWith(delegateCallbackType)
        }
    }
    
    // MARK: Action Item Setup Helpers
    
    private func flagActionItem(forSequence sequence: VSequence) -> VActionItem {
        let flagItem = VActionItem.defaultActionItemWithTitle(NSLocalizedString("Report/Flag", comment: ""),
            actionIcon: UIImage(named: "icon_flag"),
            detailText: "")
        flagItem.selectionHandler = { item in
            self.originViewController.dismissViewControllerAnimated(true) {
                self.flagSequence(sequence) { success in
                    self.dismissAndCallDelegateCallbackWith(DelegateCallback.Flag)
                }
            }
        }
        return flagItem
    }
    
    private func deleteActionItem(forSequence sequence: VSequence) -> VActionItem {
        let deleteItem = VActionItem.defaultActionItemWithTitle(NSLocalizedString("Delete", comment: ""),
            actionIcon: UIImage(named: "delete-icon"),
            detailText: "")
        deleteItem.selectionHandler = { item in
            self.originViewController.dismissViewControllerAnimated(true) {
                self.deleteSequence(sequence) { success in
                    self.dismissAndCallDelegateCallbackWith(DelegateCallback.Delete)
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
                    node: sequence.firstNode(),
                    streamID: streamId, //self.viewModel.streamId -> might be causing an issue here
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
    
    // MARK: Action Item Setup Helper
    
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
    
    // MARK: Helper
    
    func shareTextForSequence(sequence: VSequence) -> String {
        var shareText = ""
        
        if sequence.isPoll() {
            shareText = NSLocalizedString("UGCSharePollFormat", comment: "")
        }
        else if sequence.isGIFVideo() {
            shareText = NSLocalizedString("UGCShareGIFFormat", comment: "")
        }
        else if sequence.isVideo() {
            shareText = NSLocalizedString("UGCShareVideoFormat", comment: "")
        }
        else if sequence.isImage() {
            shareText = NSLocalizedString("UGCShareImageFormat", comment: "")
        }
        else if sequence.isText() {
            shareText = NSLocalizedString("UGCShareTextFormat", comment: "")
        }
        else {
            shareText = NSLocalizedString("UGCShareLinkFormat", comment: "")
        }
        
        return shareText
    }
    
    //MARK: Alert Controller
    
    func standardAlertControllerWithTitle(title: String, message: String) -> UIAlertController {
        return standardAlertControllerWithTitle(title, message: message, handler: nil)
    }
    
    func standardAlertControllerWithTitle(title: String, message: String, handler: ((UIAlertAction)->())? ) -> UIAlertController {
        let alertController = UIAlertController(title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK",
            comment: "OK Action"),
            style: UIAlertActionStyle.Default,
            handler: handler)
        alertController.addAction(okAction)
        
        return alertController
    }
    
}