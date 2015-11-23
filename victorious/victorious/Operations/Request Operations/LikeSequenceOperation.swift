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
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    
    struct UIContext {
        let originViewController: UIViewController
        let dependencyManager: VDependencyManager
        let triggeringView: UIView
    }
    
    private let sequenceID: Int64
    private let uiContext: UIContext?
    
    init( sequenceID: Int64, uiContext: UIContext? = nil ) {
        self.uiContext = uiContext
        self.sequenceID = sequenceID
        super.init( request: LikeSequenceRequest(sequenceID: sequenceID) )
    }
    
    override func onStart( completion:()->() ) {
        
        // Handle some immediate synchronous UI updates
        dispatch_sync( dispatch_get_main_queue() ) {
            VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidSelectLike )
            
            if let uiContext = self.uiContext {
                uiContext.dependencyManager.coachmarkManager().triggerSpecificCoachmarkWithIdentifier(
                    VLikeButtonCoachmarkIdentifier,
                    inViewController:uiContext.originViewController,
                    atLocation:uiContext.triggeringView.convertRect(
                        uiContext.triggeringView.bounds,
                        toView:uiContext.originViewController.view
                    )
                )
            }
        }
        
        // Handle immediate asynchronous data updates
        persistentStore.asyncFromBackground() { context in
            let uniqueElements = [ "remoteId" : Int(self.sequenceID) ]
            let sequence: VSequence = context.findOrCreateObject( uniqueElements )
            sequence.isLikedByMainUser = true
            context.saveChanges()
        }
    }
}
