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

/// A type that provides user authorization information (user ID, token, etc)
public protocol UserAuthorizationProvider {
    /// The user ID, as returned by a successful login or account create call.
    var userID: Int64 { get }
    
    /// An authorization token, as returned by a successful login or account create call.
    var token: String { get }
}

/// If no authorization information is available (because the user is not logged in and/or the endpoint
/// in use does not require authentication), this struct provides the default values that the server
/// expects in this case.
private struct DefaultAuthorizationProvider: UserAuthorizationProvider {
    let userID: Int64 = 0
    let token = ""
}

/// A type that provides client authentication information. In contract to *user* authentication,
/// which authenticates the person *using* the app, this information authenticates the app 
/// itself to the Victorious API.
public protocol ClientAuthorizationProvider {
    /// An ID that identifies this application to the Victorious API
    var appID: Int { get }
    
    /// The value of UIDevice.currentDevice().identifierForVendor, or if UIDevice is
    /// unavailable on your platform, any UUID that identifies this device.
    var deviceID: String { get }
    
    /// The value of CFBundleVersion in the application's Info.plist file
    var buildNumber: String { get }
}

private struct HTTPHeader {
    static let authorization = "Authorization"
    static let date = "Date"
    static let userAgent = "User-Agent"
    static let platform = "X-Client-Platform"
    static let osVersion = "X-Client-OS-Version"
    static let appVersion = "X-Client-App-Version"
    static let sessionID = "X-Client-Session-ID"
    static let experimentIDs = "X-Client-Experiment-IDs"
    static let firstInstallDeviceID = "X-Client-Install-Device-ID"
}

extension NSMutableURLRequest {
    private static let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // RFC2822 Format
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
        return dateFormatter
    }()
    
    /// Sets the "Authorization" header appropriately for Victorious API requests. Since the Date and User-Agent headers are
    /// used in calculating the correct Authentication header, this method calculates and sets those, too.
    public func vsdk_setAuthorizationHeader(clientAuthorizationProvider clientAuthorizationProvider: ClientAuthorizationProvider, userAuthorizationProvider: UserAuthorizationProvider = DefaultAuthorizationProvider()) {
        
        let currentDate = NSMutableURLRequest.dateFormatter.stringFromDate(NSDate())
        setValue(currentDate, forHTTPHeaderField: HTTPHeader.date)
        
        let previousUserAgent = valueForHTTPHeaderField(HTTPHeader.userAgent) ?? "victorious/\(clientAuthorizationProvider.buildNumber)"
        let newUserAgent = "\(previousUserAgent) aid:\(clientAuthorizationProvider.appID) uuid:\(clientAuthorizationProvider.deviceID) build:\(clientAuthorizationProvider.buildNumber)"
        setValue(newUserAgent, forHTTPHeaderField: HTTPHeader.userAgent)
        
        var path: String = ""
        if let URL = self.URL,
           let urlComponents = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true),
           let percentEncodedPath = urlComponents.percentEncodedPath {
            path = percentEncodedPath
        }
        let sha1String = vsdk_sha1("\(currentDate)\(path)\(newUserAgent)\(userAuthorizationProvider.token)\(self.HTTPMethod)")
        setValue("Basic \(userAuthorizationProvider.userID):\(sha1String)", forHTTPHeaderField: HTTPHeader.authorization)
    }
    
    /// Sets the value of the "X-Client-Platform" header to a constant value
    /// that has been defined in the Victorious API to identify iOS clients.
    public func vsdk_setPlatformHeader() {
        setValue("iOS", forHTTPHeaderField: HTTPHeader.platform)
    }
    
    /// Sets the value of the "X-Client-Install-Device-ID" header to the locally stored value
    /// - parameter firstInstallDeviceID: the device ID when the app is installed
    public func vsdk_setIdentiferForVendorHeader(firstInstallDeviceID deviceID: String) {
        setValue(deviceID, forHTTPHeaderField: HTTPHeader.firstInstallDeviceID)
    }
    
#if os(iOS)
    /// Sets the value of the "X-Client-OS-Version" header to the system version
    public func vsdk_setOSVersionHeader() {
        setValue(UIDevice.currentDevice().systemVersion, forHTTPHeaderField: HTTPHeader.osVersion)
    }
#endif
    
    public func vsdk_setAppVersionHeaderValue(appVersion: String) {
        setValue(appVersion, forHTTPHeaderField: HTTPHeader.appVersion)
    }

    public func vsdk_setSessionIDHeaderValue(sessionID: String) {
        setValue(sessionID, forHTTPHeaderField: HTTPHeader.sessionID)
    }
    
    public func vsdk_setExperimentsHeaderValue(experimentSettings: String) {
        setValue(experimentSettings, forHTTPHeaderField: HTTPHeader.experimentIDs)
    }
}
