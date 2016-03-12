//
//  ShowMediaContentOperation.swift
//  victorious
//
//  Created by Vincent Ho on 3/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ShowMediaContentOperation: MainQueueOperation {
    
    private let originViewController: UIViewController
    private let mediaUrl: NSURL
    private let linkType: VCommentMediaType
    
    init( originViewController: UIViewController, mediaUrl: NSURL, mediaLinkType linkType: VCommentMediaType) {
        self.originViewController = originViewController
        self.mediaUrl = mediaUrl
        self.linkType = linkType
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        let mediaLinkViewController = VAbstractMediaLinkViewController.newWithMediaUrl(mediaUrl, andMediaLinkType: linkType)
        originViewController.presentViewController(mediaLinkViewController, animated: true) {
            self.finishedExecuting()
        }
    }
    
}