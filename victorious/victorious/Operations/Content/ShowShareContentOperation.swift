
//
//  ShowShareContentOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

final class ShowShareContentOperation: AsyncOperation<Void> {
    
    fileprivate let dependencyManager: VDependencyManager
    fileprivate let content: Content
    fileprivate weak var originViewController: UIViewController?
    
    init(originViewController: UIViewController, dependencyManager: VDependencyManager, content: Content) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.content = content
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<Void>) -> Void) {
        let appInfo = VAppInfo(dependencyManager: dependencyManager)
        
        let activityViewController: UIActivityViewController = UIActivityViewController(
            activityItems: [
                content.textForSharing(),
                content.shareURL ?? NSNull()
            ],
            applicationActivities: []
        )
        
        let creatorName = appInfo?.appName ?? ""
        let emailSubject = String(format: NSLocalizedString("EmailShareSubjectFormat", comment: ""), creatorName)
        activityViewController.setValue(emailSubject, forKey: "subject")
        activityViewController.excludedActivityTypes = [UIActivityType.postToFacebook]
        activityViewController.completionWithItemsHandler = { [weak self] activityType, completed, _, activityError in
            if completed, let trackingURLs = self?.content.tracking?.trackingURLs(forKey: .share) {
                VTrackingManager.sharedInstance().trackEvent("event", parameters: [VTrackingKeyUrls : trackingURLs])
                finish(.success())
            }
            else {
                let error = NSError(domain: "ShowShareContentOperation", code: -1, userInfo: nil)
                finish(.failure(error))
            }
        }
        originViewController?.present(activityViewController, animated: true, completion: nil)
    }
}

private extension Content {
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
