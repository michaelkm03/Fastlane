//
//  StageContentFetchOperation.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class StageContentFetchOperation: AsyncOperation<Content> {
    
    // MARK: - Initializing

    init?(apiPath: APIPath, currentUserID: String, refreshStageEvent: RefreshStage) {
        guard let request = ContentFetchRequest(apiPath: apiPath, currentUserID: currentUserID, contentID: refreshStageEvent.contentID) else {
            return nil
        }
        
        self.request = request
        self.refreshStageEvent = refreshStageEvent
    }
    
    // MARK: - Executing
    
    private let request: ContentFetchRequest
    private(set) var refreshStageEvent: RefreshStage
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<Content>) -> Void) {
        let operationStartTime = Date()
        
        RequestOperation(request: request).queue { [weak self] result in
            guard let strongSelf = self else {
                finish(.cancelled)
                return
            }
            
            switch result {
                case .success(let content):
                    finish(.success(strongSelf.calculateSeekAheadTime(for: content, from: operationStartTime)))
                
                case .failure(_), .cancelled:
                    finish(result)
            }
        }
    }
    
    /// Calculated time diff, used to sync users in the video on stage.
    /// seekAheadTime = serverTime - startTime + workTime
    private func calculateSeekAheadTime(for content: Content, from operationStartTime: Date) -> Content {
        guard
            let startTime = refreshStageEvent.startTime,
            let serverTime = refreshStageEvent.serverTime
            , content.type == .video
        else {
            return content
        }
        
        let timeDiff = TimeInterval(serverTime.value - startTime.value)
        let workTime = Date().timeIntervalSince(operationStartTime)
        let seekAheadTime: Double = (timeDiff + workTime) / 1000
        
        var content = content
        content.localStartTime = Date(timeIntervalSinceNow: -seekAheadTime) as NSDate?
        return content
    }
}
