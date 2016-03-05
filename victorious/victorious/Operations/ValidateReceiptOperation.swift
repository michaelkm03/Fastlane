//
//  ValidateReceiptOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ValidateReceiptOperation: FetcherOperation {
    
    override func main() {
        let receipt = NSBundle.mainBundle().v_readReceiptData()
    }
}