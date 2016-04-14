//
//  Alert.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

public enum AlertType : String {
    /// Alerts coming back from the backend
    case LevelUp = "levelUp"
    case Achievement = "achievement"
    case StatusUpdate = "statusUpdate"
    case Toast = "toast"
    
    /// Alerts created on client side
    case ClientSideCreated = "clientSideCreated"
}

public func ==(lhs: Alert, rhs: Alert) -> Bool {
    return lhs.alertID == rhs.alertID
}

public struct Alert {
    
    public struct Parameters {
        public let backgroundVideoURL: NSURL?
        public let description: String?
        public let title: String
        public let userFanLoyalty: FanLoyalty?
        public let icons: [NSURL]?
    }
    public let alertID: Int
    public let alertType: AlertType
    public let parameters: Alert.Parameters
    
    public let dateAcknowledged: NSDate?
}

extension Alert {
    
    public init?(json: JSON) {
        guard let alertID = Int(json["id"].stringValue) ?? json["id"].int,
            let alertType = AlertType(rawValue: json["type"].string ?? ""),
            let parameters = Alert.Parameters(json: json["params"]) else {
                return nil
        }
        self.alertType = alertType
        self.parameters = parameters
        self.alertID = alertID
        self.dateAcknowledged = NSDateFormatter.vsdk_defaultDateFormatter().dateFromString(json["acknowledged_at"].stringValue)
    }
    
    /// Initialize an alert only with display information. This is provided for initializing alerts on the client side.
    /// - parameter title: Title of the alert. Required.
    /// - parameter description: Description of the alert. Optional
    /// - parameter iconURLs: An array of icons for the alert
    public init(title: String, description: String?, iconURLs: [NSURL]? = nil) {
        self.alertID = Int(NSDate().timeIntervalSince1970)
        self.alertType = .ClientSideCreated
        self.parameters = Alert.Parameters(backgroundVideoURL: nil, description: description, title: title, userFanLoyalty: nil, icons: iconURLs)
        self.dateAcknowledged = nil
    }
}

extension Alert.Parameters {
    public init?(json: JSON) {
        guard let title = json["title"].string,
            let userFanLoyalty = FanLoyalty(json: json["user"]["fanloyalty"] ) else {
                return nil
        }
        self.title          = title
        self.userFanLoyalty = userFanLoyalty
        
        description         = json["description"].string
        icons               = json["icons"].arrayValue.map { $0.stringValue }.flatMap { NSURL(string: $0) }
        
        if let urlString = json["backgroundVideo"].string where !urlString.characters.isEmpty {
            self.backgroundVideoURL = NSURL(string: urlString)
        } else {
            self.backgroundVideoURL = nil
        }
    }
}
