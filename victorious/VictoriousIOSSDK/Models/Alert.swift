//
//  Alert.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import QuartzCore

/// Different alert types, could be coming from the backend or internally triggered.
public enum AlertType: String {

    // MARK: Backend driven alerts.

    case LevelUp = "levelUp"
    case Achievement = "achievement"
    case StatusUpdate = "statusUpdate"
    case Toast = "toast"

    // MARK: Locally created alerts.

    case ClientSideCreated = "clientSideCreated"
    case WebSocketError = "WebSocketError"
}

public struct Alert: Equatable {
    public struct Parameters {
        public let title: String
        public let backgroundVideoURL: NSURL?
        public let description: String?
        public let userFanLoyalty: FanLoyalty?
        public let icons: [NSURL]?

        public init(title: String, backgroundVideoURL: NSURL? = nil, description: String? = nil, userFanLoyalty: FanLoyalty? = nil, icons: [NSURL]? = nil) {
            self.title = title
            self.backgroundVideoURL = backgroundVideoURL
            self.description = description
            self.userFanLoyalty = userFanLoyalty
            self.icons = icons
        }
    }

    public let alertID: String
    public let alertType: AlertType
    public let parameters: Alert.Parameters
    public let dateAcknowledged: NSDate?

    /// Initialize an alert only with display information. This is provided for initializing alerts on the client side.
    /// - parameter title: Title of the alert. Required.
    /// - parameter description: Description of the alert. Optional
    /// - parameter iconURLs: An array of icons for the alert
    public init(title: String, description: String?, iconURLs: [NSURL]? = nil) {
        self.alertID = String(CACurrentMediaTime())
        self.alertType = .ClientSideCreated
        self.parameters = Parameters(title: title, description: description, icons: iconURLs)
        self.dateAcknowledged = nil
    }
}

extension Alert {
    public init(webSocketError: WebSocketError) {
        alertID = String(CACurrentMediaTime())
        alertType = .WebSocketError
        parameters = Parameters(title: "Error", description: "Description")
        dateAcknowledged = nil
    }
}

extension Alert {
    public init?(json: JSON) {
        guard
            let alertID = json["id"].string,
            let alertType = AlertType(rawValue: json["type"].string ?? ""),
            let parameters = Alert.Parameters(json: json["params"])
        else {
                return nil
        }
        self.alertType = alertType
        self.parameters = parameters
        self.alertID = alertID
        self.dateAcknowledged = NSDateFormatter.vsdk_defaultDateFormatter().dateFromString(json["acknowledged_at"].stringValue)
    }
}

extension Alert.Parameters {
    public init?(json: JSON) {
        guard
            let title = json["title"].string,
            let userFanLoyalty = FanLoyalty(json: json["user"]["fanloyalty"])
            else {
                return nil
        }

        self.title          = title
        self.userFanLoyalty = userFanLoyalty
        description         = json["description"].string
        icons               = json["icons"].arrayValue.map { $0.stringValue }.flatMap { NSURL(string: $0) }

        self.backgroundVideoURL = json["backgroundVideo"].URL
    }
}

public func ==(lhs: Alert, rhs: Alert) -> Bool {
    return lhs.alertID == rhs.alertID
}
