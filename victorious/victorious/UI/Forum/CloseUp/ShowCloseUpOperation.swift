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
    private var contentID: String
    
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
    
    override func start() {
        
        guard let childDependencyManager = dependencyManager.childDependencyForKey("closeUpView")
            where !self.cancelled else {
                finishedExecuting()
                return
        }
        defer {
            finishedExecuting()
        }
        
        let header = CloseUpView.newWithDependencyManager(childDependencyManager)

        let config = GridStreamConfiguration(
            sectionInset: UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0),
            interItemSpacing: CGFloat(3),
            cellsPerRow: 3,
            allowsForRefresh: false,
            managesBackground: true
        )

        let closeUpViewController = GridStreamViewController<CloseUpView>.newWithDependencyManager(
            childDependencyManager,
            header: header,
            content: nil,
            configuration: config,
            streamAPIPath: nil
        )
        originViewController?.navigationController?.pushViewController(closeUpViewController, animated: animated)
        
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
                let replacementDictionary: [String:String] = [
                    "%%CONTENT_ID%%" : content.remoteID ?? "",
                    "%%CONTEXT%%" : childDependencyManager.context
                ]
                let apiPath: String? = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary(
                    replacementDictionary,
                    inURLString: childDependencyManager.relatedContentURL
                )

                closeUpViewController.content = content
                closeUpViewController.updateStreamAPIPath(apiPath)
            }
        }
    }
}

private extension VDependencyManager {
    var contentFetchURL: String {
        let centerScreen = childDependencyForKey("centerScreen")
        let networkResources = centerScreen?.childDependencyForKey("networkResources")
        return networkResources?.stringForKey("contentFetchURL") ?? ""
    }
    
    var relatedContentURL: String {
        return stringForKey("streamURL") ?? ""
    }
    
    var context: String {
        return stringForKey("related.content.context") ?? ""
    }
}
