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
    
    case achievement        = "achievement"
    case statusUpdate       = "statusUpdate"
    case toast              = "toast"

    // MARK: Locally created alerts.

    case clientSideCreated  = "clientSideCreated"
    case reconnectingError  = "reconnectingError"
}

public struct Alert: Equatable {
    public struct Parameters {
        public let title: String
        public let backgroundVideoURL: NSURL?
        public let description: String?
        public let userFanLoyalty: FanLoyalty?
        public let icons: [NSURL]?
        public let dismissalTime: TimeInterval?

        public init(title: String, backgroundVideoURL: NSURL? = nil, description: String? = nil, userFanLoyalty: FanLoyalty? = nil, icons: [NSURL]? = nil, dismissalTime: TimeInterval? = nil) {
            self.title = title
            self.backgroundVideoURL = backgroundVideoURL
            self.description = description
            self.userFanLoyalty = userFanLoyalty
            self.icons = icons
            self.dismissalTime = dismissalTime
        }
    }

    public let alertID: String
    public let type: AlertType
    public let parameters: Alert.Parameters
    public let dateAcknowledged: Date?

    /// Initialize an alert only with display information. This is provided for initializing alerts on the client side.
    /// - parameter title: Title of the alert. Required.
    /// - parameter description: Description of the alert. Optional
    /// - parameter iconURLs: An array of icons for the alert
    public init(title: String, description: String?, iconURLs: [NSURL]? = nil) {
        self.alertID = String(CACurrentMediaTime())
        self.type = .clientSideCreated
        self.parameters = Parameters(title: title, description: description, icons: iconURLs)
        self.dateAcknowledged = nil
    }
}

extension Alert {
    /// Initialize an alert by setting it's type and time on screen. The alert will dismiss it self after the specified amounts of time.
    /// - parameter title: Title of the alert.
    /// - parameter type: Type of alert to be presented.
    /// - parameter description: Description of the alert.
    /// - parameter dismissalTime: Time to display alert, is nil is passed in it will be presented until user dismisses it.
    public init(title: String, type: AlertType, description: String? = nil, dismissalTime: TimeInterval? = nil) {
        alertID = String(CACurrentMediaTime())
        self.type = type
        parameters = Parameters(title: title, description: description, dismissalTime: dismissalTime)
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
        self.type = alertType
        self.parameters = parameters
        self.alertID = alertID
        self.dateAcknowledged = DateFormatter.vsdk_defaultDateFormatter().date(from: json["acknowledged_at"].stringValue)
    }
}

extension Alert.Parameters {
    public init?(json: JSON) {
        guard let title = json["title"].string else {
                return nil
        }
        self.title          = title
        self.userFanLoyalty = FanLoyalty(json: json["user"]["fanloyalty"])
        description         = json["description"].string
        icons               = json["icons"].arrayValue.map { $0.stringValue }.flatMap { NSURL(string: $0) }

        self.backgroundVideoURL = json["backgroundVideo"].URL
        dismissalTime = nil
    }
}

public func ==(lhs: Alert, rhs: Alert) -> Bool {
    return lhs.alertID == rhs.alertID
}
