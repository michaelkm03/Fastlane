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
    private let sequenceID: Int64
    
    init( sequenceID: Int64, originViewController: UIViewController ) {
        self.sequenceID = sequenceID
        self.originViewController = originViewController
        super.init( request: FlagSequenceRequest(sequenceID: sequenceID) )
    }
    
    override func onError(error: NSError) {
        
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
    }
    
    override func onComplete( response: FlagSequenceRequest.ResultType, completion:()->() ) {
        
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidFlagPost )
        
        self.showAlert(
            title: NSLocalizedString( "ReportedTitle", comment: "" ),
            message: NSLocalizedString( "ReportContentMessage", comment: "" )
        )
        
        persistentStore.asyncFromBackground() { context in
            let uniqueElements = [ "remoteId" : Int(self.sequenceID) ]
            guard let sequence: VSequence = context.findObjects( uniqueElements, limit: 1).first else  {
                fatalError( "Cannot find sequence!" )
            }
            // TODO: Use this property to filter out flagged content
            // TODO: See about using this class for Comments, too
            sequence.isFlagged = true
            context.saveChanges()
            completion()
        }
    }
    
    // TODO: Remove the alert and tracking stuff
    func showAlert( title title: String, message: String ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction( UIAlertAction(title: NSLocalizedString( "OK", comment: ""), style: .Cancel, handler: nil))
        originViewController.presentViewController( alertController, animated: true, completion: nil)
    }
}
