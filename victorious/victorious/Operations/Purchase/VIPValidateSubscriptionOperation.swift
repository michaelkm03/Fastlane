//
//  VIPValidateSubscriptionOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

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
    init?(apiPath: APIPath, shouldForceSuccess: Bool = false) {
        let receiptData = receiptDataSource.readReceiptData() ?? NSData()
        let request = ValidateReceiptRequest(apiPath: apiPath, data: receiptData)
        
        if request == nil && !shouldForceSuccess {
            return nil
        }
        
        self.request = request
        self.shouldForceSuccess = shouldForceSuccess
    }
    
    // MARK: - Executing
    
    var receiptDataSource: ReceiptDataSource = Bundle.main
    
    fileprivate(set) var validationSucceeded = false
    
    fileprivate let request: ValidateReceiptRequest?
    
    let shouldForceSuccess: Bool
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<VIPStatus>) -> Void) {
        guard let request = request else {
            if shouldForceSuccess {
                let status = VIPStatus(isVIP: true)
                updateUser(status: status)
                finish(.success(status))
            }
            else {
                finish(.failure(NSError(domain: "VIPValidateSubscriptionOperation", code: -1, userInfo: [:])))
            }
            
            return
        }
        
        RequestOperation(request: request).queue { [weak self] result in
            switch result {
                case .success(let status):
                    self?.validationSucceeded = true
                    self?.updateUser(status: status)
                    finish(.success(status))
                
                case .failure(let error):
                    if self?.shouldForceSuccess == true {
                        let status = VIPStatus(isVIP: true)
                        self?.updateUser(status: status)
                        finish(.success(status))
                    } else {
                        self?.updateUser(status: nil)
                        finish(.failure(error))
                    }
                
                case .cancelled:
                    finish(.cancelled)
            }
        }
    }
    
    fileprivate func updateUser(status: VIPStatus?) {
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
        
        VCurrentUser.update(to: currentUser)
    }
}
