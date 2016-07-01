//
//  ShowFetchedCloseUpOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Fetches a piece of content and shows a close up view containing it.
class ShowFetchedCloseUpOperation: MainQueueOperation {
    private let displayModifier: ShowCloseUpDisplayModifier
    private var contentID: String
    
    init(contentID: String, displayModifier: ShowCloseUpDisplayModifier, checkPermissions: Bool = true) {
        self.displayModifier = displayModifier
        self.contentID = contentID
        super.init()
    }
    
    override func main() {
        defer {
            finishedExecuting()
        }
        
        let displayModifier = self.displayModifier
        guard
            !cancelled,
            let userID = VCurrentUser.user()?.remoteId.integerValue,
            let contentFetchURL = displayModifier.dependencyManager.contentFetchURL
        else {
            return
        }
        
        let showCloseUpOperation = ShowCloseUpOperation(contentID: contentID, displayModifier: displayModifier)
        showCloseUpOperation.rechainAfter(self).queue()
        
        let contentFetchOperation = ContentFetchOperation(
            macroURLString: contentFetchURL,
            currentUserID: String(userID),
            contentID: contentID
        )
        
        let completionBlock = showCloseUpOperation.completionBlock
        contentFetchOperation.rechainAfter(showCloseUpOperation).queue() { results, _, _ in
            guard let shownCloseUpView = showCloseUpOperation.displayedCloseUpView else {
                completionBlock?()
                return
            }
            
            guard let content = results?.first as? ContentModel else {
                // Display error message.
                shownCloseUpView.updateError()
                completionBlock?()
                return
            }
            
            if content.isVIPOnly {
                let dependencyManager = displayModifier.dependencyManager
                let showVIPGateOperation = ShowVIPGateOperation(originViewController: shownCloseUpView, dependencyManager: dependencyManager)
                
                showVIPGateOperation.rechainAfter(self).queue() { _ in
                    if !showVIPGateOperation.showedGate || showVIPGateOperation.allowedAccess {
                        shownCloseUpView.updateContent(content)
                    }
                    else {
                        shownCloseUpView.navigationController?.popViewControllerAnimated(true)
                    }
                    completionBlock?()
                }
            }
            else {
                shownCloseUpView.updateContent(content)
                completionBlock?()
            }
        }
    }
}

private extension VDependencyManager {
    var contentFetchURL: String? {
        return networkResources?.stringForKey("contentFetchURL")
    }
}
