//
//  ShowCloseUpOperation.swift
//  victorious
//
//  Created by Vincent Ho on 4/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ShowCloseUpOperation: MainQueueOperation {
    
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    private weak var originViewController: UIViewController?
    private var content: VViewedContent?
    var fetcherOperation: ViewedContentFetchOperation
    
    init?( originViewController: UIViewController,
          dependencyManager: VDependencyManager,
          contentID: String) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.animated = true
        
        guard let userID = VCurrentUser.user()?.remoteId.integerValue,
            let request = ViewedContentFetchRequest(
                macroURLString: dependencyManager.contentFetchURL,
                currentUserID: "\(userID)",
                contentID: contentID
            ) else {
                return nil
        }
        
        fetcherOperation = ViewedContentFetchOperation(request: request)
        super.init()
    }
}

private extension VDependencyManager {
    var contentFetchURL: String {
        let centerScreen = childDependencyForKey("centerScreen")
        let networkResources = centerScreen?.childDependencyForKey("networkResources")
        return networkResources?.stringForKey("contentFetchURL") ?? ""
    }
}
