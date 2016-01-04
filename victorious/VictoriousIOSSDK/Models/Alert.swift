//
//  Alert.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum AlertType : String {
    case LevelUp = "levelUp"
    case Achievement = "achievement"
}

public func ==(lhs: Alert, rhs: Alert) -> Bool {
    return lhs.alertID == rhs.alertID
}

public struct Alert {
    
    public struct Parameters {
        public let backgroundVideoURL: NSURL?
        public let description: String
        public let title: String
        public let userFanLoyalty: FanLoyalty
        public let icons: [NSURL]
    }
    
    public let alertID: Int64
    public let alertType: AlertType
    public let parameters: Alert.Parameters
    public let dateAcknowledged: NSDate?
}

extension Alert {
    
    public init?(json: JSON) {
        guard let alertID = Int64(json["id"].stringValue),
            let alertType = AlertType(rawValue: json["type"].string ?? ""),
            let parameters = Alert.Parameters(json: json["params"]) else {
                return nil
        }
        self.alertType = alertType
        self.parameters = parameters
        self.alertID = alertID
        self.dateAcknowledged = NSDateFormatter.v_defaultDateFormatter.dateFromString(json["acknowledged_at"].stringValue)
    }
}

extension Alert.Parameters {
    public init?(json: JSON) {
        guard let description = json["description"].string,
            let title = json["title"].string,
            let userFanLoyalty = FanLoyalty(json: json["user"]["fanloyalty"] ) else {
                return nil
        }
        self.userFanLoyalty = userFanLoyalty
        self.description    = description
        self.title          = title
        
        icons               = json["icons"].arrayValue.map { $0.stringValue }.flatMap { NSURL(string: $0) }
        
        if let urlString = json["backgroundVideo"].string where !urlString.characters.isEmpty {
            self.backgroundVideoURL = NSURL(string: urlString)
        } else {
            self.backgroundVideoURL = nil
        }
    }
}
