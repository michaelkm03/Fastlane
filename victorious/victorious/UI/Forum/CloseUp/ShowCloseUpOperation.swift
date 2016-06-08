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

/// Shows a close up view displaying the provided content. Does not check
/// if user has permission to view the content; to check permissions first
/// create a ShowPermissionedCloseUpOperation instead.
class ShowCloseUpOperation: MainQueueOperation {
    
    private let displayModifier: ShowCloseUpDisplayModifier
    private var content: ContentModel
    
    init(content: ContentModel,
         displayModifier: ShowCloseUpDisplayModifier) {
        self.displayModifier = displayModifier
        self.content = content
        super.init()
    }
    
    override func start() {
        
        defer {
            finishedExecuting()
        }
        
        guard !cancelled,
            let childDependencyManager = displayModifier.dependencyManager.childDependencyForKey("closeUpView"),
            let originViewController = displayModifier.originViewController else {
                return
        }
        
        let apiPath = APIPath(templatePath: childDependencyManager.relatedContentURL, macroReplacements: [
            "%%CONTENT_ID%%": content.id ?? "",
            "%%CONTEXT%%" : childDependencyManager.context
            ])
        
        let closeUpViewController = CloseUpContainerViewController(
            dependencyManager: childDependencyManager,
            content: content,
            streamAPIPath: apiPath
        )
        
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
