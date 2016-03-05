//
//  NSBundle+ReceiptData.swift
//  victorious
//
//  Created by Alex Tamoykin on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension NSBundle {
    func v_readReceiptData() -> NSData? {
        guard let appStoreReceiptURL = appStoreReceiptURL else {
            VLog("Failed to obtain appStoreReceiptURL")
            return nil
        }
        return NSData(contentsOfURL: appStoreReceiptURL)
    }
}
