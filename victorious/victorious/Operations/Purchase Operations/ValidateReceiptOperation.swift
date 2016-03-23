//
//  ValidateReceiptOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ValidateReceiptOperation: RemoteFetcherOperation, RequestOperation {
    
    var receiptDataSource: ReceiptDataSource = NSBundle.mainBundle()
    
    lazy var request: ValidateReceiptRequest! = {
        let receiptData = self.receiptDataSource.readReceiptData() ?? NSData()
        return ValidateReceiptRequest(data: receiptData)
    }()
    
    override func main() {
        guard request != nil else {
            cancel()
            return
        }
        
        // Let the backend validate the receipt and they will let us know at next login
        // whether or not the user is a VIP user
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
