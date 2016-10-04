//
//  NSBundle+AppStoreReceipt.swift
//  victorious
//
//  Created by Alex Tamoykin on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

protocol ReceiptDataSource {
    func readReceiptData() -> NSData?
}

extension Bundle: ReceiptDataSource {
    
    func readReceiptData() -> NSData? {
        guard let appStoreReceiptURL = appStoreReceiptURL else {
            v_log("Failed to obtain appStoreReceiptURL")
            return nil
        }
        return NSData(contentsOf: appStoreReceiptURL)
    }
}
