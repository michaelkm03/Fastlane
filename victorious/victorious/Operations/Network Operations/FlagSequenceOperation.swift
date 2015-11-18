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
    
    let originViewController: UIViewController
    
    init( sequenceID: Int64, originViewController: UIViewController ) {
        self.originViewController = originViewController
        super.init( request: FlagSequenceRequest(sequenceID: sequenceID) )
    }
    
    override func onResponse(response: FlagSequenceRequest.ResultType) {
        let persistentStore = PersistentStore()
        guard let sequence: VSequence = persistentStore.backgroundContext.findObjects( [ "remoteId" : Int(request.sequenceID) ], limit: 1).first else  {
            fatalError( "Cannot find sequence!" )
        }
        // TODO: Use this property to filter out flagged content
        // TODO: See about using this class for Comments, too
        sequence.isFlagged = true
        persistentStore.backgroundContext.saveChanges()
    }
    
    override func onComplete(error: NSError?) {
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
