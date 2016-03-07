//
//  ValidateReceiptOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VIPValidateOperation: FetcherOperation, RequestOperation {
    
    lazy var request: ValidateReceiptRequest! = {
        let receiptData = NSBundle.mainBundle().v_readReceiptData() ?? NSData()
        return ValidateReceiptRequest(data: receiptData)
    }()
    
    override func main() {
        NSThread.sleepForTimeInterval(2.0)
        
        let executeSemphore = dispatch_semaphore_create(0)
        dispatch_async(dispatch_get_main_queue()) {
            self.onComplete(true) {
                dispatch_semaphore_signal( executeSemphore )
            }
        }
        dispatch_semaphore_wait( executeSemphore, DISPATCH_TIME_FOREVER )
    }
    
    func onComplete(result: ValidateReceiptRequest.ResultType, completion: () -> () ) {
        persistentStore.createBackgroundContext().v_performBlock() { context in
            VCurrentUser.user(inManagedObjectContext: context)?.isVIPSubscriber = NSNumber(bool: result)
            context.v_save()
            completion()
        }
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
                VIPValidateOperation().after(self).queue()
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
                VIPValidateOperation().after(self).queue()
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
