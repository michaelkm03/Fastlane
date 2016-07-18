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
        let appInfo = VAppInfo(dependencyManager: dependencyManager)
        
        let fbActivity: VFacebookActivity = VFacebookActivity()
        let activityViewController: UIActivityViewController = UIActivityViewController(
            activityItems: [
                sequence,
                sequence.textForSharing(),
                sequence.shareURL() ?? NSNull()
            ],
            applicationActivities: [
                fbActivity
            ]
        )
        
        let creatorName = appInfo.appName
        let emailSubject = String(format: NSLocalizedString("EmailShareSubjectFormat", comment: ""), creatorName)
        activityViewController.setValue(emailSubject, forKey: "subject")
        activityViewController.excludedActivityTypes = [UIActivityTypePostToFacebook]
        activityViewController.completionWithItemsHandler = { [weak self] activityType, completed, _, activityError in
            self?.activityViewDidFinish(activityType: activityType ?? "", completed: completed, activityError: activityError)
        }
        
        originViewController.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    private func activityViewDidFinish(activityType activityType: String, completed: Bool, activityError: NSError?) {
        // Tracking code removed
        originViewController.reloadInputViews()
        finishedExecuting()
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
