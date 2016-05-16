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
    private var viewedContent: VViewedContent?
    var fetcherOperation: ViewedContentFetchOperation
    
    init?( originViewController: UIViewController,
          dependencyManager: VDependencyManager,
          contentID: String,
          animated: Bool = true) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.animated = animated
        
        guard let userID = VCurrentUser.user()?.remoteId.integerValue else {
            return nil
        }
        fetcherOperation = ViewedContentFetchOperation(macroURLString: dependencyManager.contentFetchURL, currentUserID: String(userID), contentID: contentID)
        super.init()
        fetcherOperation.before(self).queue() { results, error, cancelled in
            if let viewedContent = results?.first as? VViewedContent {
                self.viewedContent = viewedContent
            }
        }
    }
    
    override func start() {
        
        guard let childDependencyManager = dependencyManager.childDependencyForKey("closeUpView"),
            viewedContent = viewedContent
            where !self.cancelled else {
                finishedExecuting()
                return
        }
        defer {
            finishedExecuting()
        }
        
        let header = CloseUpView.newWithDependencyManager(childDependencyManager)
        
        let replacementDictionary: [String:String] = [
            "%%CONTENT_ID%%" : viewedContent.contentID,
            "%%CONTEXT%%" : childDependencyManager.context
        ]
        let apiPath = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary(
            replacementDictionary,
            inURLString: childDependencyManager.relatedContentURL
        )

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
            content: viewedContent,
            configuration: config,
            streamAPIPath: apiPath
        )
        originViewController?.navigationController?.pushViewController(closeUpViewController, animated: animated)
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
