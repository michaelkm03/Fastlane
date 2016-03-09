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
