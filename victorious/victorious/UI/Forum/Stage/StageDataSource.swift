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
    
    private var currentContentFetchOperation: ContentViewFetchOperation?
    
    // MARK: Initialiation
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager.childDependencyForKey("networkResources")
    }
    
    // MARK: ForumEventReceiver
    
    func receiveEvent(event: ForumEvent) {
        guard let dependencyManager = dependencyManager else {
            v_log("No dependency manager avaliable in StageDataSource, bailing.")
            return
        }
        
        guard let stageEvent = event as? RefreshStage where stageEvent.section == RefreshSection.VIPStage else {
            return
        }
        
        guard let currentUserID = VCurrentUser.user()?.remoteId.stringValue
            where VCurrentUser.isLoggedIn() else {
                v_log("The current user is not logged and got a refresh stage message. App is in an inconsistent state. VCurrentUser -> \(VCurrentUser.user())")
                return
        }
        
        currentContentFetchOperation?.cancel()
        
        let contentFetchURL = dependencyManager.contentFetchURL
        if let contentViewFetchOperation = ContentViewFetchOperation(macroURLString: contentFetchURL, currentUserID: currentUserID, contentID: stageEvent.contentID) {
            currentContentFetchOperation = contentViewFetchOperation
            contentViewFetchOperation.queue() { [weak self] results, error, canceled in
                guard let strongSelf = self,
                    let delegate = strongSelf.delegate else {
                        return
                }
                if let result = results?.first as? Stageable {
                    delegate.startPlayingMedia(result)
                }
            }
        }
    }
}

private extension VDependencyManager {
    var contentFetchURL: String {
        return stringForKey("contentFetchURL")
    }
}
