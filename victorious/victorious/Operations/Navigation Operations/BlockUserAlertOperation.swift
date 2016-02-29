//
//  BlockUserAlertOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class BlockUserAlertOperation: NavigationOperation {
    
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    private let user: VUser
    private let presentationCompletion: (()->())?
    var didBlockUser: Bool
    var errorCode: Int
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager, user: VUser, presentationCompletion: (()->())? ) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.user = user
        self.presentationCompletion = presentationCompletion
        self.didBlockUser = false
        self.errorCode = 0
        super.init()
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        let alertController = UIAlertController(title: nil,
            message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"),
            style: UIAlertActionStyle.Cancel,
            handler: { action in
                self.finishedExecuting()
        }))
        
        let userID = user.remoteId.integerValue
        let shouldUnblockUser = user.isBlockedByMainUser?.boolValue == true
        let blockUserBlock: (UIAlertAction) -> () = { action in
            
            if shouldUnblockUser {
                
                UnblockUserOperation(userID: userID).queue() { (results, error) in
                    
                    if let error = error {
                        let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
                        VTrackingManager.sharedInstance().trackEvent( VTrackingEventUnblockUserDidFail, parameters: params )
                        self.originViewController.v_showErrorDefaultError()
                        
                    } else if error == nil {
                        VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidUnblockUser )
                    }
                    self.finishedExecuting()
                }
            } else {
                BlockUserOperation(userID: userID).queue() { (results, error) in
                    
                    if let error = error {
                        let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
                        VTrackingManager.sharedInstance().trackEvent( VTrackingEventBlockUserDidFail, parameters: params )
                        self.originViewController.v_showErrorDefaultError()
                        
                    } else if error == nil {
                        VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidBlockUser )
                        self.originViewController.v_showFlaggedUserAlert()
                    }
                    self.finishedExecuting()
                }
            }
        }
        
        let title = shouldUnblockUser ? NSLocalizedString("UnblockUser", comment: "") : NSLocalizedString("BlockUser", comment: "")
        alertController.addAction(UIAlertAction(title: title,
            style: UIAlertActionStyle.Destructive, handler: blockUserBlock))
        
        originViewController.presentViewController(alertController, animated: true, completion: presentationCompletion)
    }
}
