//
//  VIPValidateSubscriptionOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VIPValidateSubscriptionOperation: AsyncOperation<VIPStatus> {
    
    // MARK: - Initializing
    
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
        }
        else if shouldForceSuccess {
            self.init(url: NSURL(), shouldForceSuccess: true)
        }
        else {
            return nil
        }
    }
    
    private init(url: NSURL, shouldForceSuccess: Bool) {
        self.url = url
        self.shouldForceSuccess = shouldForceSuccess
    }
    
    // MARK: - Executing
    
    var receiptDataSource: ReceiptDataSource = NSBundle.mainBundle()
    
    private let url: NSURL
    
    private(set) var validationSucceeded = false
    
    lazy var request: ValidateReceiptRequest! = {
        let receiptData = self.receiptDataSource.readReceiptData() ?? NSData()
        return ValidateReceiptRequest(data: receiptData, url: self.url)
    }()
    
    let shouldForceSuccess: Bool
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(finish: (result: OperationResult<VIPStatus>) -> Void) {
        guard request != nil else {
            if shouldForceSuccess {
                let status = VIPStatus(isVIP: true)
                updateUser(status: status)
                finish(result: .success(status))
            }
            else {
                finish(result: .failure(NSError(domain: "VIPValidateSubscriptionOperation", code: -1, userInfo: [:])))
            }
            
            return
        }
        
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventSentProductReceiptToBackend)
        
        RequestOperation(request: request).queue { [weak self] result in
            switch result {
                case .success(let status):
                    self?.validationSucceeded = true
                    self?.updateUser(status: status)
                    finish(result: .success(status))
                
                case .failure(let error):
                    if self?.shouldForceSuccess == true {
                        let status = VIPStatus(isVIP: true)
                        self?.updateUser(status: status)
                        finish(result: .success(status))
                    } else {
                        self?.updateUser(status: nil)
                        finish(result: .failure(error))
                    }
                
                case .cancelled:
                    finish(result: .cancelled)
            }
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
