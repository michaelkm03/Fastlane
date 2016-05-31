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
    private var contentID: String?
    private var content: ContentModel?
    
    init?( originViewController: UIViewController,
           dependencyManager: VDependencyManager,
           contentID: String,
           animated: Bool = true) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.animated = animated
        self.contentID = contentID
        super.init()
    }
    
    init?( originViewController: UIViewController,
           dependencyManager: VDependencyManager,
           content: ContentModel,
           animated: Bool = true) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.animated = animated
        self.content = content
        super.init()
    }
    
    override func start() {
        
        guard let childDependencyManager = dependencyManager.childDependencyForKey("closeUpView"),
            let originViewController = originViewController
            where !self.cancelled else {
                finishedExecuting()
                return
        }
        defer {
            finishedExecuting()
        }
        
        let replacementDictionary: [String:String] = [
            "%%CONTENT_ID%%" : contentID ?? content?.id ?? "",
            "%%CONTEXT%%" : childDependencyManager.context
        ]
        let apiPath: String? = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary(
            replacementDictionary,
            inURLString: childDependencyManager.relatedContentURL
        )
        
        let closeUpViewController = CloseUpContainerViewController(
            dependencyManager: childDependencyManager,
            content: content,
            streamAPIPath: apiPath
        )
        
        originViewController.navigationController?.pushViewController(closeUpViewController, animated: animated)
        
        if content == nil {
            guard let contentID = contentID else {
                assertionFailure("contentID should not be nil if content is nil")
                return
            }
            /// CloseUpHeader loading
            guard let userID = VCurrentUser.user()?.remoteId.integerValue else {
                return
            }
            ContentFetchOperation(
                macroURLString: dependencyManager.contentFetchURL,
                currentUserID: String(userID),
                contentID: contentID
                ).after(self).queue() { results, error, cancelled in
                    if let content = results?.first as? VContent {
                        closeUpViewController.updateContent(content)
                    }
            }
        }
    }
}

private extension VDependencyManager {
    var contentFetchURL: String {
        return networkResources?.stringForKey("contentFetchURL") ?? ""
    }
    
    var relatedContentURL: String {
        return stringForKey("streamURL") ?? ""
    }
    
    var context: String {
        return stringForKey("related.content.context") ?? ""
    }
}
