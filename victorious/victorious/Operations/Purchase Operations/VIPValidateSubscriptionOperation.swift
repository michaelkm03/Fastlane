//
//  VIPValidateSubscriptionOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VIPValidateSubscriptionOperation: RemoteFetcherOperation, RequestOperation {
    
    var receiptDataSource: ReceiptDataSource = NSBundle.mainBundle()
    
    private let url: NSURL
    
    private(set) var validationSucceeded = false
    
    lazy var request: ValidateReceiptRequest! = {
        let receiptData = self.receiptDataSource.readReceiptData() ?? NSData()
        return ValidateReceiptRequest(data: receiptData, url: self.url)
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
    convenience init?(url: NSURL?, shouldForceSuccess: Bool = false) {
        if let url = url {
            self.init(url: url, shouldForceSuccess: shouldForceSuccess)
        } else if shouldForceSuccess {
            self.init(url: NSURL(), shouldForceSuccess: true)
        } else {
            return nil
        }
    }
    
    private init(url: NSURL, shouldForceSuccess: Bool) {
        self.url = url
        self.shouldForceSuccess = shouldForceSuccess
    }
    
    override func main() {
        guard request != nil else {
            if shouldForceSuccess {
                updateUser(status: VIPStatus(isVIP: true) )
            }
            return
        }
        
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventSentProductReceiptToBackend)
        // Let the backend validate the receipt and they will let us know at next login
        // whether or not the user is a VIP user
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: onError)
    }
    
    func onComplete(status: VIPStatus) {
        validationSucceeded = true
        updateUser(status: status)
    }
    
    private func onError(error: NSError) {
        if shouldForceSuccess {
            self.error = nil
            updateUser(status: VIPStatus(isVIP: true) )
        } else {
            updateUser(status: nil)
        }
    }
    
    private func updateUser(status status: VIPStatus?) {
        guard var currentUser = VCurrentUser.user else {
            return
        }
        
        if let status = status {
            // We only want to update a user's vip status from false to true
            // If it's already true, we let next app launch's parsing handle the user's VIP status.
            if currentUser.vipStatus?.isVIP != true {
                currentUser.vipStatus = status
            }
        }
        else {
            currentUser.vipStatus = nil
        }
        
        dispatch_sync(dispatch_get_main_queue()) {
            VCurrentUser.update(to: currentUser)
        }
    }
}

class VIPClearSubscriptionOperation: FetcherOperation {
    
    override func main() {
        guard var user = VCurrentUser.user else {
            return
        }
        user.vipStatus = nil
        VCurrentUser.update(to: user)
    }
}
