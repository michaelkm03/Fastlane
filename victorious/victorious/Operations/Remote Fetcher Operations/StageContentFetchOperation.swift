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
    
    private var refreshStageEvent: RefreshStage?

    required init(request: ContentFetchRequest) {
        self.request = request
    }

    convenience init(macroURLString: String, currentUserID: String, refreshStageEvent: RefreshStage) {
        let request = ContentFetchRequest(macroURLString: macroURLString, currentUserID: currentUserID, contentID: refreshStageEvent.contentID)
        
        self.init(request: request)
        self.refreshStageEvent = refreshStageEvent
    }

    override func main() {
        operationStartTime = NSDate()
        
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }

    func onComplete(content: ContentFetchRequest.ResultType) {
        // Calculated time diff, used to sync users in the video.
        // startTime = serverTime - startTime + workTime
        if let refreshStageEvent = refreshStageEvent,
            let startTime = refreshStageEvent.startTime,
            let operationStartTime = operationStartTime {
            
            // TODO: Refactor this piece of logic
            let timeDiff = refreshStageEvent.serverTime?.timeIntervalSinceDate(startTime) ?? 0
            let workTime = NSDate().timeIntervalSinceDate(operationStartTime)
            let seekAheadTime = timeDiff + workTime

            content.seekAheadTime = seekAheadTime
        }

        self.results = [content]
    }
}
