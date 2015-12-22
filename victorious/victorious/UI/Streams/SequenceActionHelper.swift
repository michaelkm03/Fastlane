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
            UnlikeSequenceOperation( sequenceID: Int64(sequence.remoteId)! ).queue() { error in
                completion?( error == nil )
            }
        } else {
            guard let sequenceID = Int64(sequence.remoteId) else {
                fatalError( "We have a big problem. Check the parsing code." )
            }
            LikeSequenceOperation( sequenceID: sequenceID ).queue() { error in
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
        RepostSequenceOperation(nodeID: Int64(node.remoteId.integerValue) ).queue { error in
            if let _ = error {
                let params = [ VTrackingKeyErrorMessage : error?.localizedDescription ?? "" ]
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventRepostDidFail, parameters:params )
            } else {
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidRepost)
            }
            completion?( error == nil )
        }
    }
    
    func flagSequence( sequence: VSequence, fromViewController viewController: UIViewController, completion:((Bool) -> Void)? ) {
        
        FlagSequenceOperation(sequenceID: Int64(sequence.remoteId)! ).queue() { error in
            if let error = error {
                let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
                VTrackingManager.sharedInstance().trackEvent( VTrackingEventFlagPostDidFail, parameters: params )
                
                if error.code == Int(kVCommentAlreadyFlaggedError) {
                    self.showAlert(
                        title: NSLocalizedString( "ReportedTitle", comment: "" ),
                        message: NSLocalizedString( "ReportContentMessage", comment: "" ),
                        viewController: viewController
                    )
                } else {
                    self.showAlert(
                        title: NSLocalizedString( "WereSorry", comment: "" ),
                        message: NSLocalizedString( "ErrorOccured", comment: "" ),
                        viewController: viewController
                    )
                }
            }
            else {
                VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidFlagPost )
                
                self.showAlert(
                    title: NSLocalizedString( "ReportedTitle", comment: "" ),
                    message: NSLocalizedString( "ReportContentMessage", comment: "" ),
                    viewController: viewController
                )
            }
            completion?( error == nil )
        }
    }
    
    func showAlert( title title: String, message: String, viewController: UIViewController ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction( UIAlertAction(title: NSLocalizedString( "OK", comment: ""), style: .Cancel, handler: nil))
        viewController.presentViewController( alertController, animated: true, completion: nil)
    }
}
