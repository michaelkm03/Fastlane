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
    private var currentContent: ContentModel?
    
    // MARK: Initialiation
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager.networkResources
    }
    
    // MARK: ForumEventReceiver
    
    func receive(event: ForumEvent) {
        guard let dependencyManager = dependencyManager else {
            v_log("No dependency manager avaliable in StageDataSource, bailing.")
            return
        }
        
        switch event {
            case .refreshStage(let stageEvent):
                guard let currentUserID = VCurrentUser.user?.remoteId.stringValue where VCurrentUser.isLoggedIn() else {
                    v_log("The current user is not logged in and got a refresh stage message. App is in an inconsistent state. VCurrentUser -> \(VCurrentUser.user)")
                    return
                }
                
                guard let contentFetchURL = dependencyManager.contentFetchURL else {
                    return
                }

                // Don't replace the content on the Main Stage if it's the same content since we might be getting 
                // multiple Main stage messages during the contents lifetime.
                if currentContent?.id == stageEvent.contentID && stageEvent.section == .main {
                    return
                }
                
                currentContentFetchOperation?.cancel()
                
                currentContentFetchOperation = StageContentFetchOperation(macroURLString: contentFetchURL, currentUserID: currentUserID, refreshStageEvent: stageEvent)
                
                currentContentFetchOperation?.queue() { [weak self] results, error, canceled in
                    guard
                        !canceled,
                        let content = results?.first as? ContentModel
                    else {
                        return
                    }

                    // The meta data is transferred over to the StageContent object in order to simplify the usage by only having one model.
                    let stageContent = StageContent(content: content, metaData: stageEvent.stageMetaData)
                    self?.delegate?.addStageContent(stageContent)
                    self?.currentContent = content
                }
                
            case .closeStage(_):
                currentContentFetchOperation?.cancel()
                delegate?.removeContent()
                currentContent = nil
            
            case .showCaptionContent(let content):
                delegate?.addCaptionContent(content)
            
            default:
                break
            }
    }
}

private extension VDependencyManager {
    var contentFetchURL: String? {
        return stringForKey("contentFetchURL")
    }
}
