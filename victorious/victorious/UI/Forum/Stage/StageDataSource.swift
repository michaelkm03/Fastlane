//
//  StageDataSource.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class StageDataSource: ForumEventReceiver {
    fileprivate static let backendStartTimeThreshold: Int64 = 1000
    
    weak var delegate: Stage?
    
    fileprivate let dependencyManager: VDependencyManager?
    
    fileprivate var currentContentFetchOperation: StageContentFetchOperation?
    fileprivate var currentContent: Content?
    
    // MARK: Initialiation
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager.networkResources
    }
    
    // MARK: ForumEventReceiver
    
    let childEventReceivers = [ForumEventReceiver]()
    
    func receive(_ event: ForumEvent) {
        guard let dependencyManager = dependencyManager else {
            Log.error("No dependency manager avaliable in StageDataSource, bailing.")
            return
        }
        
        switch event {
            case .refreshStage(let stageEvent):
                guard let currentUserID = VCurrentUser.user?.id else {
                    Log.error("The current user is not logged in and got a refresh stage message. App is in an inconsistent state. VCurrentUser -> \(VCurrentUser.user)")
                    return
                }
                
                guard let contentFetchAPIPath = dependencyManager.contentFetchAPIPath else {
                    Log.warning("Missing contentFetchURL to fetch stage content. DependencyManager: \(dependencyManager)")
                    return
                }

                // Don't replace the content on the Main Stage if it's the same content and start time 
                // is the same since we might be getting multiple Main stage messages during the contents lifetime.
                let sameContent = currentContent?.id == stageEvent.contentID
                let oldStartTime = currentContentFetchOperation?.refreshStageEvent.startTime ?? Timestamp(value: 0)
                let sameStartTime = stageEvent.startTime?.within(threshold: StageDataSource.backendStartTimeThreshold, of: oldStartTime) ?? false
                if sameContent && sameStartTime && stageEvent.section == .main {
                    return
                }
                
                currentContentFetchOperation?.cancel()
                
                currentContentFetchOperation = StageContentFetchOperation(apiPath: contentFetchAPIPath, currentUserID: String(currentUserID), refreshStageEvent: stageEvent)
                
                currentContentFetchOperation?.queue { [weak self] result in
                    switch result {
                        case .success(let content):
                            // The meta data is transferred over to the StageContent object in order to simplify the usage by only having one model.
                            let stageContent = StageContent(content: content, metaData: stageEvent.stageMetaData)
                            self?.delegate?.addStageContent(stageContent)
                            self?.currentContent = content
                        
                        case .failure(_), .cancelled:
                            Log.warning("content fetch failed after receiving stage refresh event: \(stageEvent), Error: \(result.error)")
                    }
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
    var contentFetchAPIPath: APIPath? {
        return apiPath(forKey: "contentFetchURL")
    }
}
