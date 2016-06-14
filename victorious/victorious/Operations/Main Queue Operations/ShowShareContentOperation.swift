
//
//  ShowShareContentOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ShowShareContentOperation: MainQueueOperation {
    
    private let dependencyManager: VDependencyManager
    private let content: ContentModel
    private weak var originViewController: UIViewController?
    
    init(originViewController: UIViewController, dependencyManager: VDependencyManager, content: ContentModel) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.content = content
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        let appInfo = VAppInfo(dependencyManager: dependencyManager)
        
        let fbActivity: VFacebookActivity = VFacebookActivity()
        let activityViewController: UIActivityViewController = UIActivityViewController(
            activityItems: [
                content.textForSharing(),
                content.shareURL ?? NSNull()
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
        
        originViewController?.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    private func activityViewDidFinish(activityType activityType: String, completed: Bool, activityError: NSError?) {
        /// Future: Tracking
        finishedExecuting()
    }
}

private extension ContentModel {
    func textForSharing() -> String {
        let shareText: String
        
        switch type {
            case .gif: shareText = NSLocalizedString("UGCShareGIFFormat", comment: "")
            case .video: shareText = NSLocalizedString("UGCShareVideoFormat", comment: "")
            case .image: shareText = NSLocalizedString("UGCShareImageFormat", comment: "")
            case .text: shareText = NSLocalizedString("UGCShareTextFormat", comment: "")
            case .link: shareText = NSLocalizedString("UGCShareLinkFormat", comment: "")
        }
        
        return shareText
    }
}
