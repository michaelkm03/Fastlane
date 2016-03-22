//
//  ShowQueuedDeeplinkOperation.swift
//  victorious
//
//  Created by Tian Lan on 3/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class ShowQueuedDeeplinkOperation: MainQueueOperation {
    
    let deepLinkReceiver: VDeeplinkReceiver
    
    init( deepLinkReceiver: VDeeplinkReceiver) {
        self.deepLinkReceiver = deepLinkReceiver
    }
    
    override func start() {
        beganExecuting()
        deepLinkReceiver.receiveQueuedDeeplink()
        finishedExecuting()
    }
}
