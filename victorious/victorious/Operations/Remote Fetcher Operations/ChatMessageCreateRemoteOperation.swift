//
//  ChatMessageCreateRemoteOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class ChatMessageCreateRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    private static let defaultCreationURL: NSURL = {
        return NSURL(fileURLWithPath: "api/text/create", relativeToURL: VEnvironmentManager.sharedInstance().currentEnvironment.baseURL)
    }()
    
    let request: ChatMessageCreateRequest!
    
    var trackingManager: VEventTracker = VTrackingManager.sharedInstance()
    
    init(textCreationURL: NSURL?, text: String ) {
        let url = textCreationURL ?? ChatMessageCreateRemoteOperation.defaultCreationURL
        request = ChatMessageCreateRequest(textCreationURL: url, text: text)
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: onError )
    }
    
    private func onComplete(sequence: ChatMessageCreateRequest.ResultType) {
        // FUTURE: Add tracking call once spec'd
    }
    
    private func onError(error: NSError) {
        // FUTURE: Add tracking call once spec'd
    }
}
