//
//  VIPStatus.swift
//  victorious
//
//  Created by Patrick Lynch on 4/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct VIPStatus {
    public let isVIP: Bool
    public let purchasedProductIdentifier: String?
    
    public init?(json: JSON) {
        guard let isVIP = json["active"].bool else {
            return nil
        }
        self.isVIP = isVIP
        self.purchasedProductIdentifier = json["current_sku"].string
    }
    
    public init(isVIP: Bool, purchasedProductIdentifier: String? = nil) {
        self.isVIP = isVIP
        self.purchasedProductIdentifier = purchasedProductIdentifier
    }
}
