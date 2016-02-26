//
//  SequenceActionHelper.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

@objc class SequenceActionHelper: NSObject {
    
    func likeSequence(sequence: VSequence, triggeringView: UIView, originViewController: UIViewController, dependencyManager: VDependencyManager, completion: ((Bool) -> Void)?) {
        
        if sequence.isLikedByMainUser.boolValue {
            UnlikeSequenceOperation( sequenceID: sequence.remoteId ).queue() { (results, error) in
                completion?( error == nil )
            }
            
        } else {
            LikeSequenceOperation( sequenceID: sequence.remoteId ).queue() { (results, error) in
                VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidSelectLike )
                dependencyManager.coachmarkManager().triggerSpecificCoachmarkWithIdentifier(
                    VLikeButtonCoachmarkIdentifier,
                    inViewController:originViewController,
                    atLocation:triggeringView.convertRect(
                        triggeringView.bounds,
                        toView:originViewController.view
                    )
                )
                completion?( error == nil )
            }
        }
    }
    
    func repostNode( node: VNode, completion: ((Bool) -> Void)?) {
        RepostSequenceOperation(nodeID: node.remoteId.integerValue ).queue { (results, error) in
            
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
