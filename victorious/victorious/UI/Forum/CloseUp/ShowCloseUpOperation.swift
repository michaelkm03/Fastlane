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
        
        if let content = content {
            showContentAfterCheckingPermissions(content)
        } else {
            /// FUTURE: do a new load of the content anyway
            guard let contentID = contentID else {
                assertionFailure("contentID should not be nil if content is nil")
                finishedExecuting()
                return
            }
            /// CloseUpHeader loading
            guard let userID = VCurrentUser.user()?.remoteId.integerValue else {
                return
            }
            
            //Assumes operation queue can run more than one operation concurrently
            ContentFetchOperation(
                macroURLString: dependencyManager.contentFetchURL,
                currentUserID: String(userID),
                contentID: contentID
            ).queue() { [weak self] results, _, _ in
                if let content = results?.first as? VContent {
                    self?.showContentAfterCheckingPermissions(content)
                }
            }
        }
    }
    
    private func showContentAfterCheckingPermissions(content: ContentModel) {
        if content.isVIPOnly {
            let scaffold = dependencyManager.scaffoldViewController()
            let showVIPGateOperation = ShowVIPGateOperation(originViewController: scaffold, dependencyManager: dependencyManager)

            //Assumes operation queue can run more than one operation concurrently
            showVIPGateOperation.queue() { [weak self] _ in
                if !showVIPGateOperation.showedGate || showVIPGateOperation.allowedAccess {
                    self?.showCloseUpView(content)
                } else {
                    self?.finishedExecuting()
                }
            }
        } else {
            showCloseUpView(content)
        }
    }
    
    private func showCloseUpView(content: ContentModel) {
        
        guard let childDependencyManager = dependencyManager.childDependencyForKey("closeUpView"),
            let originViewController = originViewController
            where !self.cancelled else {
                finishedExecuting()
                return
        }
        defer {
            finishedExecuting()
        }
        
        let apiPath = APIPath(templatePath: childDependencyManager.relatedContentURL, macroReplacements: [
            "%%CONTENT_ID%%": contentID ?? content.id ?? "",
            "%%CONTEXT%%" : childDependencyManager.context
            ])
        
        let closeUpViewController = CloseUpContainerViewController(
            dependencyManager: childDependencyManager,
            content: content,
            streamAPIPath: apiPath
        )
        
        if let originViewController = originViewController as? UINavigationController {
            originViewController.pushViewController(closeUpViewController, animated: animated)
        } else {
            originViewController.navigationController?.pushViewController(closeUpViewController, animated: animated)
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
