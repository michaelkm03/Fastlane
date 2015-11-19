//
//  FlagSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FlagSequenceOperation: RequestOperation<FlagSequenceRequest> {
    
    private let originViewController: UIViewController
    private let persistentStore = PersistentStore()
    private let flaggedContent = VFlaggedContent()
    
    init( sequenceID: Int64, originViewController: UIViewController ) {
        self.originViewController = originViewController
        super.init( request: FlagSequenceRequest(sequenceID: sequenceID) )
    }
    
    override func onResponse(response: FlagCommentRequest.ResultType) {
        persistentStore.syncFromBackground() { context in
            if let sequence: VSequence = context.findObjects([ "remoteId" : String(self.request.sequenceID) ]).first {
                context.destroy( sequence )
                context.saveChanges()
            }
        }
    }
    
    override func onComplete(error: NSError?) {
        flaggedContent.addRemoteId( String(request.sequenceID), toFlaggedItemsWithType: .StreamItem)
        
        if let error = error {
            let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
            VTrackingManager.sharedInstance().trackEvent( VTrackingEventFlagPostDidFail, parameters: params )
            
            if error.code == Int(kVCommentAlreadyFlaggedError) {
                self.showAlert(
                    title: NSLocalizedString( "ReportedTitle", comment: "" ),
                    message: NSLocalizedString( "ReportContentMessage", comment: "" )
                )
            } else {
                self.showAlert(
                    title: NSLocalizedString( "WereSorry", comment: "" ),
                    message: NSLocalizedString( "ErrorOccured", comment: "" )
                )
            }
        } else {
            VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidFlagPost )
            
            self.showAlert(
                title: NSLocalizedString( "ReportedTitle", comment: "" ),
                message: NSLocalizedString( "ReportContentMessage", comment: "" )
            )
        }
    }
    
    func showAlert( title title: String, message: String ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction( UIAlertAction(title: NSLocalizedString( "OK", comment: ""), style: .Cancel, handler: nil))
        originViewController.presentViewController( alertController, animated: true, completion: nil)
    }
}


class FlagCommentOperation: RequestOperation<FlagCommentRequest> {
    
    private let originViewController: UIViewController
    private let persistentStore = PersistentStore()
    private let flaggedContent = VFlaggedContent()
    
    init( commentID: Int64, originViewController: UIViewController ) {
        self.originViewController = originViewController
        super.init( request: FlagCommentRequest(commentID: commentID) )
    }
    
    override func onResponse(response: FlagCommentRequest.ResultType) {
        persistentStore.syncFromBackground() { context in
            if let comment: VComment = context.findObjects([ "remoteId" : String(self.request.commentID) ]).first {
                context.destroy( comment )
                context.saveChanges()
            }
        }
    }
    
    override func onComplete(error: NSError?) {
        flaggedContent.addRemoteId( String(request.commentID), toFlaggedItemsWithType: .Comment)
    }
}
