//
//  ShowPermissionedCloseUpOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// Shows a close up view for a given piece of content after checking
/// permissions and displaying a vip gate as appropriate.
class ShowPermissionedCloseUpOperation: MainQueueOperation {
    private let displayModifier: ShowCloseUpDisplayModifier
    private var content: ContentModel
    
    init(content: ContentModel, displayModifier: ShowCloseUpDisplayModifier) {
        self.displayModifier = displayModifier
        self.content = content
        super.init()
    }
    
    override func start() {
        defer {
            finishedExecuting()
        }
        
        guard !cancelled else {
            return
        }
        
        let displayModifier = self.displayModifier
        let dependencyManager = displayModifier.dependencyManager
        let content = self.content
        
        if content.isVIPOnly {
            let scaffold = dependencyManager.scaffoldViewController()
            let showVIPFlowOperation = ShowVIPFlowOperation(originViewController: scaffold, dependencyManager: dependencyManager)
            
            let completionBlock = self.completionBlock
            showVIPFlowOperation.rechainAfter(self).queue() { _ in
                if !showVIPFlowOperation.showedGate || showVIPFlowOperation.allowedAccess {
                    ShowCloseUpOperation(content: content, displayModifier: displayModifier).rechainAfter(showVIPFlowOperation).queue() { _ in
                        completionBlock?()
                    }
                }
                else {
                    completionBlock?()
                }
            }
        } else {
            ShowCloseUpOperation(content: content, displayModifier: displayModifier).rechainAfter(self).queue()
        }
    }
}
