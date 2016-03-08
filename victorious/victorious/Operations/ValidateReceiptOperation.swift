//
//  ValidateReceiptOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VIPValidateReceiptOperation: FetcherOperation, RequestOperation {
    
    lazy var request: VIPPurchaseRequest! = {
        let receiptData = NSBundle.mainBundle().v_readReceiptData() ?? NSData()
        return VIPPurchaseRequest(data: receiptData)
    }()
    
    override func main() {
        // Let the backend validate the receipt and they will let us know at next login
        // whether or not the user is a VIP user
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}

class VIPSubscriptionSuccessOperation: FetcherOperation {
    
    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            VCurrentUser.user(inManagedObjectContext: context)?.isVIPSubscriber = true
            context.v_save()
        }
        
        VIPValidateReceiptOperation().after(self).queue()
    }
}

class VIPSubscribeOperation: Operation {
    
    let productIdentifier: String
    
    var error: NSError?
    
    init(productIdentifier: String) {
        self.productIdentifier = productIdentifier
    }
    
    override func start() {
        super.start()
        beganExecuting()
        
        VPurchaseManager.sharedInstance().purchaseProductWithIdentifier(productIdentifier,
            success: { results in
                self.finishedExecuting()
                VIPSubscriptionSuccessOperation().rechainAfter(self).queue()
            },
            failure: { error in
                dispatch_sync(dispatch_get_main_queue()) {
                    self.error = error
                }
                self.finishedExecuting()
            }
        )
    }
}

class RestorePurchasesOperation: Operation {
    
    var error: NSError?
    
    override func start() {
        super.start()
        beganExecuting()
        
        VPurchaseManager.sharedInstance().restorePurchasesSuccess(
            { results in
                self.finishedExecuting()
                VIPSubscriptionSuccessOperation().rechainAfter(self).queue()
            },
            failure: { error in
                dispatch_sync(dispatch_get_main_queue()) {
                    self.error = error
                }
                self.finishedExecuting()
            }
        )
    }
}
