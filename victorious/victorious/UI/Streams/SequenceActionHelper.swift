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
            let uiContext = LikeSequenceOperation.UIContext(
                originViewController: originViewController,
                dependencyManager: dependencyManager,
                triggeringView: triggeringView
            )
            LikeSequenceOperation( sequenceID: Int64(sequence.remoteId)!, uiContext: uiContext ).queue() { error in
                completion?( error == nil )
            }
        }
    }
    
    func repostNode( node: VNode, completion: ((Bool) -> Void)?) {
        RepostSequenceOperation(nodeID: Int64(node.remoteId.integerValue) ).queue { error in
            completion?( error == nil )
        }
    }
    
    func flagSequence( sequence: VSequence, fromViewController viewController: UIViewController, completion:((Bool) -> Void)? ) {
        FlagSequenceOperation(sequenceID: Int64(sequence.remoteId)! ).queue() { error in
            
            defer {
                completion?( error == nil )
            }
            
            if let error = error {
                let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
                VTrackingManager.sharedInstance().trackEvent( VTrackingEventFlagPostDidFail, parameters: params )
                
                if error.code == Int(kVCommentAlreadyFlaggedError) {
                    self.showAlert( onViewController: viewController,
                        title: NSLocalizedString( "ReportedTitle", comment: "" ),
                        message: NSLocalizedString( "ReportContentMessage", comment: "" )
                    )
                } else {
                    self.showAlert( onViewController: viewController,
                        title: NSLocalizedString( "WereSorry", comment: "" ),
                        message: NSLocalizedString( "ErrorOccured", comment: "" )
                    )
                }
            } else {
                VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidFlagPost )
                
                self.showAlert( onViewController: viewController,
                    title: NSLocalizedString( "ReportedTitle", comment: "" ),
                    message: NSLocalizedString( "ReportContentMessage", comment: "" )
                )
            }
        }
    }
    
    func showAlert( onViewController viewController: UIViewController, title: String, message: String ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction( UIAlertAction(title: NSLocalizedString( "OK", comment: ""), style: .Cancel, handler: nil))
        viewController.presentViewController( alertController, animated: true, completion: nil)
    }
}