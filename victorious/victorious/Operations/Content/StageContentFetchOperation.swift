//
//  StageContentFetchOperation.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class StageContentFetchOperation: AsyncOperation<Content> {
    
    // MARK: - Initializing

    init(macroURLString: String, currentUserID: String, refreshStageEvent: RefreshStage) {
        self.request = ContentFetchRequest(macroURLString: macroURLString, currentUserID: currentUserID, contentID: refreshStageEvent.contentID)
        self.refreshStageEvent = refreshStageEvent
    }
    
    // MARK: - Executing
    
    private let request: ContentFetchRequest
    private(set) var refreshStageEvent: RefreshStage
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(finish: (result: OperationResult<Content>) -> Void) {
        let operationStartTime = NSDate()
        
        RequestOperation(request: request).queue { [weak self] result in
            guard let strongSelf = self else {
                finish(result: .cancelled)
                return
            }
            
            switch result {
                case .success(let content):
                    finish(result: .success(strongSelf.calculateSeekAheadTime(for: content, from: operationStartTime)))
                
                case .failure(_), .cancelled:
                    finish(result: result)
            }
        }
    }
    
    /// Calculated time diff, used to sync users in the video on stage.
    /// seekAheadTime = serverTime - startTime + workTime
    private func calculateSeekAheadTime(for content: Content, from operationStartTime: NSDate) -> Content {
        guard
            let startTime = refreshStageEvent.startTime,
            let serverTime = refreshStageEvent.serverTime
            where content.type == .video
        else {
            return content
        }
        
        let timeDiff = NSTimeInterval(serverTime.value - startTime.value)
        let workTime = NSDate().timeIntervalSinceDate(operationStartTime)
        let seekAheadTime: Double = (timeDiff + workTime) / 1000
        
        content.localStartTime = NSDate(timeIntervalSinceNow: -seekAheadTime)
        
        return content
    }
}
