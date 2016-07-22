//
//  StageContentFetchOperation.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class StageContentFetchOperation: RemoteFetcherOperation, RequestOperation {
    
    internal let request: ContentFetchRequest!
    
    // Used to calculated the offset in videos.
    private var operationStartTime: NSDate?
    
    private var refreshStageEvent: RefreshStage

    init(macroURLString: String, currentUserID: String, refreshStageEvent: RefreshStage) {
        let request = ContentFetchRequest(macroURLString: macroURLString, currentUserID: currentUserID, contentID: refreshStageEvent.contentID)
        self.request = request
        self.refreshStageEvent = refreshStageEvent
    }

    override func main() {
        guard !cancelled else {
            return
        }
        
        operationStartTime = NSDate()
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }

    func onComplete(content: ContentFetchRequest.ResultType) {
        let result = calculateSeekAheadTime(for: content)
        self.results = [result]
    }
    
    /// Calculated time diff, used to sync users in the video on stage.
    /// seekAheadTime = serverTime - startTime + workTime
    private func calculateSeekAheadTime(for content: Content) -> Content {
        guard
            let startTime = refreshStageEvent.startTime,
            let serverTime = refreshStageEvent.serverTime,
            let operationStartTime = operationStartTime
            where content.type == .video
        else {
            return content
        }
        
        let timeDiff = serverTime.timeIntervalSinceDate(startTime)
        let workTime = NSDate().timeIntervalSinceDate(operationStartTime)
        let seekAheadTime = timeDiff + workTime
        
        content.videoStartTime = NSDate(timeIntervalSinceNow: -seekAheadTime)
        
        return content
    }
}
