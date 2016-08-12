//
//  VIPSubscribeOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VIPSubscribeOperation: BackgroundOperation {
    let product: VProduct
    let trackingDependencyManager: VDependencyManager
    
    var purchaseManager: VPurchaseManagerType = VPurchaseManager.sharedInstance()
    
    init(product: VProduct, trackingDependencyManager: VDependencyManager) {
        self.product = product
        self.trackingDependencyManager = trackingDependencyManager
    }
    
    override func start() {
        guard didConfirmActionFromDependencies else {
            cancel()
            finishedExecuting()
            return
        }
        
        beganExecuting()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.purchaseSubscription()
        }
    }
    
    func purchaseSubscription() {
        let success = { (results: Set<NSObject>?) in
            // Force success because we have to deliver the product even if the sever fails for any reason
            let validatationOperation = VIPValidateSuscriptionOperation(shouldForceSuccess: true)
            validatationOperation.after(self).queue() { _ in
                if validatationOperation.validationSucceeded {
                    VTrackingManager.sharedInstance().trackEvent(VTrackingEventRecievedProductReceiptFromBackend)
                }
            }
            self.finishedExecuting()
        }
        let failure = { (error: NSError?) in
            if error == nil {
                self.cancel()
            } else {
                self.error = error
            }
            self.finishedExecuting()
        }
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventSentProductReceiptToBackend)
        purchaseManager.purchaseProduct(product, success: success, failure: failure)
    }
}
