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
    public let endDate: NSDate?
    
    public init?(json: JSON) {
        guard let isVIP = json["active"].bool,
            let dateString = json["subscriptionEnd"].string,
            let endDate = NSDateFormatter.vsdk_defaultDateFormatter().dateFromString(dateString) else {
                return nil
        }
        self.isVIP = isVIP
        self.endDate = endDate
    }
    
    public init(isVIP: Bool, endDate: NSDate? = nil) {
        self.isVIP = isVIP
        self.endDate = endDate
    }
}
