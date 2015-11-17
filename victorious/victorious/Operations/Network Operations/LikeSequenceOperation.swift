//
//  LikeSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class LikeSequenceOperation: RequestOperation<LikeSequenceRequest> {
    
    struct UIContext {
        let originViewController: UIViewController
        let dependencyManager: VDependencyManager
        let triggeringView: UIView
    }
    
    let context: UIContext?
    
    init( sequenceID: Int64, context: UIContext? = nil ) {
        self.context = context
        super.init( request: LikeSequenceRequest(sequenceID: sequenceID) )
    }
    
    override func onStart() {
        super.onStart()
        
        // Handle some immediate synchronous UI updates
        dispatch_sync( dispatch_get_main_queue() ) {
            VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidSelectLike )
            
            if let context = self.context {
                context.dependencyManager.coachmarkManager().triggerSpecificCoachmarkWithIdentifier(
                    VLikeButtonCoachmarkIdentifier,
                    inViewController:context.originViewController,
                    atLocation:context.triggeringView.convertRect(
                        context.triggeringView.bounds,
                        toView:context.originViewController.view
                    )
                )
            }
        }
        
        // Handle immediate asynchronous data updates
        let dataStore = PersistentStore.backgroundContext
        let uniqueElements = [ "remoteId" : Int(request.sequenceID) ]
        let sequence: VSequence = dataStore.findOrCreateObject( uniqueElements )
        sequence.isLikedByMainUser = true
        dataStore.saveChanges()
    }
}

class UnlikeSequenceOperation: RequestOperation<LikeSequenceRequest> {
    
    init( sequenceID: Int64 ) {
        super.init( request: LikeSequenceRequest(sequenceID: sequenceID) )
    }
    
    override func onStart() {
        super.onStart()
        
        dispatch_sync( dispatch_get_main_queue() ) {
            VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidSelectLike )
        }
        
        let dataStore = PersistentStore.backgroundContext
        let uniqueElements = [ "remoteId" : Int(request.sequenceID) ]
        let sequence: VSequence = dataStore.findOrCreateObject( uniqueElements )
        sequence.isLikedByMainUser = false
        dataStore.saveChanges()
    }
}
