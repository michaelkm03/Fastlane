//
//  StageContentFetchOperation.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class StageContentFetchOperation: RemoteFetcherOperation, RequestOperation {
    
    internal let request: ViewedContentFetchRequest!
    
    // Used to calculated the offset in videos.
    private var operationStartTime: NSDate?
    
    private var refreshStageEvent: RefreshStage?

    required init(request: ViewedContentFetchRequest) {
        self.request = request
    }

    convenience init?(macroURLString: String, currentUserID: String, refreshStageEvent: RefreshStage) {
        guard let request = ViewedContentFetchRequest(macroURLString: macroURLString,
                                                    currentUserID: currentUserID,
                                                    contentID: refreshStageEvent.contentID) else {
                                                        v_log("Failed to create StageContentFetchOperation since request failed to initialize. Using macro URL string -> \(macroURLString)")
                                                        return nil
        }
        
        self.init(request: request)
        self.refreshStageEvent = refreshStageEvent
    }

    override func main() {
        operationStartTime = NSDate()
        
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }

    func onComplete(result: ViewedContentFetchRequest.ResultType) {
        let content = result.content
        
        // Calculated time diff, used to sync users in the video.
        // startTime = serverTime - startTime + workTime
        if let refreshStageEvent = refreshStageEvent,
            let startTime = refreshStageEvent.startTime,
            let operationStartTime = operationStartTime,
            var stageContent = content.stageContent {

            let timeDiff = refreshStageEvent.serverTime.timeIntervalSinceDate(startTime)
            let workTime = NSDate().timeIntervalSinceDate(operationStartTime)
            let seekAheadTime = timeDiff + workTime

            stageContent.updateSeekAheadTime(seekAheadTime)
            content.stageContent = stageContent
        }

        self.results = [content]
    }
}
