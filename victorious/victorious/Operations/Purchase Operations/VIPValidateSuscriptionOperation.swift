//
//  VIPValidateSuscriptionOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VIPValidateSuscriptionOperation: RemoteFetcherOperation, RequestOperation {
    
    var receiptDataSource: ReceiptDataSource = NSBundle.mainBundle()
    
    lazy var request: ValidateReceiptRequest! = {
        let receiptData = self.receiptDataSource.readReceiptData() ?? NSData()
        return ValidateReceiptRequest(data: receiptData)
    }()
    
    let shouldForceSuccess: Bool
    
    /// Pings the server with receipt data from the bundle and sets the current user
    /// as a valid VIP scriber if a successful response was returned. 
    ///
    /// - parameter shouldForceSuccess: Allows calling code to force validation to
    /// succeed and VIP access granted regardless of the response from the server.
    /// This is necessary in the case where a StoreKit transaction may succeed, but
    /// the validation on the server fails.  In such a case, we err in favor of the
    /// user to ensure we deliver any digital products immediately after purchase,
    /// as per Apple's IAP UX requirements.
    init(shouldForceSuccess: Bool = false) {
        self.shouldForceSuccess = shouldForceSuccess
    }
    
    override func main() {
        guard request != nil else {
            if shouldForceSuccess {
                onComplete()
            }
            return
        }
        
        // Let the backend validate the receipt and they will let us know at next login
        // whether or not the user is a VIP user
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete(result: ValidateReceiptRequest.ResultType) {
        setCurrentUserValidated(true)
    }
    
    private func onError(error: NSError) {
        if shouldForceSuccess {
            self.error = nil
            setCurrentUserValidated(true)
        } else {
            setCurrentUserValidated(false)
        }
    }
    
    private func setCurrentUserValidated(validated: Bool) {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            VCurrentUser.user(inManagedObjectContext: context)?.isVIPSubscriber = validated
            context.v_save()
        }
    }
}
