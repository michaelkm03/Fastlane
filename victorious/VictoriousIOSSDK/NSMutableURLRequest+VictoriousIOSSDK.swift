//
//  NSMutableURLRequest+VictoriousIOSSDK.swift
//  victorious
//
//  Created by Josh Hinman on 8/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import CoreLocation
import Foundation

#if os(iOS)
    
    import UIKit
    
#endif

/// Encapsulates information needed to execute authenticated requests to the Victorious API
public struct AuthenticationContext {
    /// The user ID, as returned by a successful login or account create call.
    public let userID: Int
    
    /// An authorization token, as returned by a successful login or account create call.
    public let token: String
    
    public init(userID: Int, token: String) {
        self.userID = userID
        self.token = token
    }
}

/// If no authentication information is available (because the user is not logged in and/or the endpoint
/// in use does not require authentication), these are the default values that the server
/// expects in this case.
private let defaultAuthenticationContext = AuthenticationContext(userID: 0, token: "")

/// Encapsulates metadata used in the execution of a request to the Victorious API.
public struct RequestContext {
    /// An ID that identifies this application to the Victorious API
    public let appID: Int
    
    /// The value of UIDevice.currentDevice().identifierForVendor, or if UIDevice is
    /// unavailable on your platform, any UUID that identifies this device.
    public let deviceID: String
    
    /// The value of deviceID when the app was first installed.
    ///
    /// - seealso: `deviceID`
    public let firstInstallDeviceID: String
    
    /// The value of CFBundleVersion in the application's Info.plist file
    public let buildNumber: String
    
    /// The value of CFBundleShortVersionString in the application's Info.plist file
    public let appVersion: String
    
    /// This value should only change when the user leaves the app
    public let sessionID: String?
    
    public let experimentIDs: Set<Int>
    
    public init(appID: Int, deviceID: String, firstInstallDeviceID: String, buildNumber: String, appVersion: String, experimentIDs: Set<Int> = [], sessionID: String? = nil) {
        self.appID = appID
        self.deviceID = deviceID
        self.firstInstallDeviceID = firstInstallDeviceID
        self.buildNumber = buildNumber
        self.appVersion = appVersion
        self.experimentIDs = experimentIDs
        self.sessionID = sessionID
    }
}

private struct HTTPHeader {
    static let authorization = "Authorization"
    static let date = "Date"
    static let userAgent = "User-Agent"
    static let appID = "X-Client-App-ID"
    static let platform = "X-Client-Platform"
    static let osVersion = "X-Client-OS-Version"
    static let appVersion = "X-Client-App-Version"
    static let sessionID = "X-Client-Session-ID"
    static let experimentIDs = "X-Client-Experiment-IDs"
    static let firstInstallDeviceID = "X-Client-Install-Device-ID"
}

extension URLRequest {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // RFC2822 Format
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT") as TimeZone!
        return dateFormatter
    }()
    
    /// Sets the "Authorization" header appropriately for Victorious API requests. Since the Date and User-Agent headers are
    /// used in calculating the correct Authentication header, this method calculates and sets those, too.
    public mutating func vsdk_setAuthorizationHeader(requestContext: RequestContext, authenticationContext: AuthenticationContext = defaultAuthenticationContext) {
        
        let currentDate = URLRequest.dateFormatter.string(from: Date())
        setValue(currentDate, forHTTPHeaderField: HTTPHeader.date)
        
        let previousUserAgent = value(forHTTPHeaderField: HTTPHeader.userAgent) ?? "victorious/\(requestContext.buildNumber)"
        let newUserAgent = "\(previousUserAgent) aid:\(requestContext.appID) uuid:\(requestContext.deviceID) build:\(requestContext.buildNumber)"
        setValue(newUserAgent, forHTTPHeaderField: HTTPHeader.userAgent)
        
        var path: String = ""
        if let URL = self.url,
           let urlComponents = NSURLComponents(url: URL, resolvingAgainstBaseURL: true),
           let percentEncodedPath = urlComponents.percentEncodedPath {
            path = percentEncodedPath
        }
        let sha1String = vsdk_sha1("\(currentDate)\(path)\(newUserAgent)\(authenticationContext.token)\(self.httpMethod!)")
        setValue("Basic \(authenticationContext.userID):\(sha1String)", forHTTPHeaderField: HTTPHeader.authorization)
    }
    
    /// Sets the "X-App-ID" header to the given value.
    public mutating func vsdk_setAppIDHeader(to appID: Int) {
        setValue("\(appID)", forHTTPHeaderField: HTTPHeader.appID)
    }
    
    /// Sets the value of the "X-Client-Platform" header to a constant value
    /// that has been defined in the Victorious API to identify iOS clients.
    public mutating func vsdk_setPlatformHeader() {
        setValue("iOS", forHTTPHeaderField: HTTPHeader.platform)
    }
    
    /// Sets the value of the "X-Client-Install-Device-ID" header to the locally stored value
    /// - parameter firstInstallDeviceID: the device ID when the app is installed
    public mutating func vsdk_setIdentiferForVendorHeader(firstInstallDeviceID deviceID: String) {
        setValue(deviceID, forHTTPHeaderField: HTTPHeader.firstInstallDeviceID)
    }
    
#if os(iOS)
    /// Sets the value of the "X-Client-OS-Version" header to the system version
    public mutating func vsdk_setOSVersionHeader() {
        setValue(UIDevice.current.systemVersion, forHTTPHeaderField: HTTPHeader.osVersion)
    }
#endif
    
    public mutating func vsdk_setAppVersionHeaderValue(_ appVersion: String) {
        setValue(appVersion, forHTTPHeaderField: HTTPHeader.appVersion)
    }

    public mutating func vsdk_setSessionIDHeaderValue(_ sessionID: String) {
        setValue(sessionID, forHTTPHeaderField: HTTPHeader.sessionID)
    }
    
    public mutating func vsdk_setExperimentsHeaderValue(_ experimentSettings: String) {
        setValue(experimentSettings, forHTTPHeaderField: HTTPHeader.experimentIDs)
    }
}
