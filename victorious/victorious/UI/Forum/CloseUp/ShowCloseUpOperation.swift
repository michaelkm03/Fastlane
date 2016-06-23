//
//  ShowCloseUpOperation.swift
//  victorious
//
//  Created by Vincent Ho on 4/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// Encapsulates values used when displaying the close up view
/// and other view controllers associated with these operations
struct ShowCloseUpDisplayModifier {
    let dependencyManager: VDependencyManager
    let animated: Bool
    weak var originViewController: UIViewController?
    
    init(dependencyManager: VDependencyManager, originViewController: UIViewController, animated: Bool = true) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.animated = animated
    }
}

/// Shows a close up view displaying the provided content.
class ShowCloseUpOperation: MainQueueOperation {
    private let displayModifier: ShowCloseUpDisplayModifier
    private var content: ContentModel?
    private var contentID: String?
    private(set) var displayedCloseUpView: CloseUpContainerViewController?
    
    static func showOperation(forContent content: ContentModel, displayModifier: ShowCloseUpDisplayModifier) -> MainQueueOperation {
        return ShowPermissionedCloseUpOperation(content: content, displayModifier: displayModifier)
    }
    
    static func showOperation(forContentID contentID: String, displayModifier: ShowCloseUpDisplayModifier) -> MainQueueOperation {
        return ShowFetchedCloseUpOperation(contentID: contentID, displayModifier: displayModifier)
    }
    
    init(content: ContentModel, displayModifier: ShowCloseUpDisplayModifier) {
        self.displayModifier = displayModifier
        self.content = content
        super.init()
    }
    
    init(contentID: String, displayModifier: ShowCloseUpDisplayModifier) {
        self.displayModifier = displayModifier
        self.contentID = contentID
        super.init()
    }
    
    override func start() {
        defer {
            finishedExecuting()
        }
        
        guard
            !cancelled,
            let childDependencyManager = displayModifier.dependencyManager.childDependencyForKey("closeUpView"),
            let originViewController = displayModifier.originViewController,
            let contentID = contentID ?? content?.id
        else {
                return
        }
        
        let apiPath = APIPath(templatePath: childDependencyManager.relatedContentURL, macroReplacements: [
            "%%CONTENT_ID%%": contentID,
            "%%CONTEXT%%" : childDependencyManager.context
        ])
        
        let closeUpViewController = CloseUpContainerViewController(
            dependencyManager: childDependencyManager,
            contentID: contentID,
            content: content,
            streamAPIPath: apiPath
        )
        displayedCloseUpView = closeUpViewController
        
        let animated = displayModifier.animated
        if let originViewController = originViewController as? UINavigationController {
            originViewController.pushViewController(closeUpViewController, animated: animated)
        } else {
            originViewController.navigationController?.pushViewController(closeUpViewController, animated: animated)
        }
    }
}

private extension VDependencyManager {
    var relatedContentURL: String {
        return stringForKey("streamURL") ?? ""
    }
    
    var context: String {
        return stringForKey("related.content.context") ?? ""
    }
}
