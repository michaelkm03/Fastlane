//
//  ShareSequenceOperation.swift
//  victorious
//
//  Created by Vincent Ho on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ShowShareSequenceOperation: MainQueueOperation {
    
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    private let sequence: VSequence
    private let streamID: String?
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager, sequence: VSequence, streamID: String?) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.sequence = sequence
        self.streamID = streamID
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectShare)
        let appInfo: VAppInfo = VAppInfo(dependencyManager: dependencyManager)
        
        let fbActivity: VFacebookActivity = VFacebookActivity()
        let activityViewController: UIActivityViewController = UIActivityViewController(
            activityItems: [
                sequence,
                sequence.textForSharing(),
                sequence.shareURL() ?? NSNull()
            ],
            applicationActivities:[
                fbActivity
            ]
        )
        
        let creatorName = appInfo.appName
        let emailSubject = String(format: NSLocalizedString("EmailShareSubjectFormat", comment: ""), creatorName)
        activityViewController.setValue(emailSubject, forKey: "subject")
        activityViewController.excludedActivityTypes = [UIActivityTypePostToFacebook]
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            
            var tracking: VTracking?
            if let streamID = self.streamID {
                tracking = self.sequence.streamItemPointer(streamID: streamID)?.tracking
            }
            else {
                tracking = self.sequence.streamItemPointerForStandloneStreamItem()?.tracking
            }
            assert(tracking != nil, "Cannot track 'share' event because tracking data is missing.")
            
            if completed {
                let params = [
                    VTrackingKeySequenceCategory : self.sequence.category ?? "",
                    VTrackingKeyShareDestination : activityType ?? "",
                    VTrackingKeyUrls : tracking?.share ?? []
                ]
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidShare, parameters: params)
            }
            else if let activityError = activityError {
                let params = [
                    VTrackingKeySequenceCategory : self.sequence.category ?? "",
                    VTrackingKeyShareDestination : activityType ?? "",
                    VTrackingKeyUrls : tracking?.share ?? [],
                    VTrackingKeyErrorMessage : activityError.localizedDescription
                ]
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidShare, parameters: params)
            }
            
            self.originViewController.reloadInputViews()
            self.finishedExecuting()
        }
        
        originViewController.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
}

private extension VSequence {
    func textForSharing() -> String {
        var shareText = ""
        
        if isPoll() {
            shareText = NSLocalizedString("UGCSharePollFormat", comment: "")
        }
        else if isGIFVideo() {
            shareText = NSLocalizedString("UGCShareGIFFormat", comment: "")
        }
        else if isVideo() {
            shareText = NSLocalizedString("UGCShareVideoFormat", comment: "")
        }
        else if isImage() {
            shareText = NSLocalizedString("UGCShareImageFormat", comment: "")
        }
        else if isText() {
            shareText = NSLocalizedString("UGCShareTextFormat", comment: "")
        }
        else {
            shareText = NSLocalizedString("UGCShareLinkFormat", comment: "")
        }
        
        return shareText
    }
    
}
