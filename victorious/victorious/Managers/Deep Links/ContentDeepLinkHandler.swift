//
//  ContentDeepLinkHandler.swift
//  victorious
//
//  Created by Vincent Ho on 6/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

private let kContentDeeplinkURLHostComponent = "content";


class ContentDeepLinkHandler: NSObject, VDeeplinkHandler {
    private var dependencyManager: VDependencyManager
    private weak var originViewController: UIViewController?
    
    init(dependencyManager: VDependencyManager, originViewController: UIViewController) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
    }
    
    var requiresAuthorization: Bool = false
    
    func displayContentForDeeplinkURL(url: NSURL, completion: VDeeplinkHandlerCompletionBlock?) {
        guard canDisplayContentForDeeplinkURL(url),
            let contentID = url.v_firstNonSlashPathComponent(),
            let originViewController = originViewController else {
            completion?(false, nil)
            return
        }
        
        ShowCloseUpOperation(
            originViewController: originViewController,
            dependencyManager: dependencyManager,
            contentID: contentID
        )?.queue()
        
        
    }
    
    func canDisplayContentForDeeplinkURL(url: NSURL) -> Bool {
        let isHostValid = url.host == kContentDeeplinkURLHostComponent
        let isContentValid = url.v_firstNonSlashPathComponent() != nil
        return isHostValid && isContentValid
    }
}
