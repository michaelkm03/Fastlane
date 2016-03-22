//
//  ShowQueuedDeeplinkOperation.swift
//  victorious
//
//  Created by Tian Lan on 3/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class ShowQueuedDeeplinkOperation: MainQueueOperation {
    
    override func start() {
        beganExecuting()
        VRootViewController.sharedRootViewController()?.deepLinkReceiver.receiveQueuedDeeplink()
        finishedExecuting()
    }
}
