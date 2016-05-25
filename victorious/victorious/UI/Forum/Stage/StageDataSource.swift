//
//  StageDataSource.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class StageDataSource: ForumEventReceiver {
    
    weak var delegate: Stage?

    private let dependencyManager: VDependencyManager?
    
    private var currentContentFetchOperation: StageContentFetchOperation?
    
    // MARK: Initialiation
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager.childDependencyForKey("networkResources")
    }
    
    // MARK: ForumEventReceiver
    
    func receive(event: ForumEvent) {
        guard let dependencyManager = dependencyManager else {
            v_log("No dependency manager avaliable in StageDataSource, bailing.")
            return
        }
        
        guard let stageEvent = event as? RefreshStage where stageEvent.section == RefreshSection.VIPStage else {
            return
        }
        
        guard let currentUserID = VCurrentUser.user()?.remoteId.stringValue
            where VCurrentUser.isLoggedIn() else {
                v_log("The current user is not logged in and got a refresh stage message. App is in an inconsistent state. VCurrentUser -> \(VCurrentUser.user())")
                return
        }

        currentContentFetchOperation?.cancel()
        
        let contentFetchURL = dependencyManager.contentFetchURL
        let stageContentFetchOperation = StageContentFetchOperation(macroURLString: contentFetchURL, currentUserID: currentUserID, refreshStageEvent: stageEvent)
        currentContentFetchOperation = stageContentFetchOperation
        stageContentFetchOperation.queue() { [weak self] results, error, canceled in
            guard let strongSelf = self,
                let delegate = strongSelf.delegate
                where canceled != true else {
                    return
            }
            if let content = results?.first as? Content,
                let stageContent = content.stageContent {
                delegate.addContent(stageContent)
            }
        }
    }
}

private extension VDependencyManager {
    var contentFetchURL: String {
        return stringForKey("contentFetchURL")
    }
}
