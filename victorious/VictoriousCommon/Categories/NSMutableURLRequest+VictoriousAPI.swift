//
//  NSMutableURLRequest+VictoriousAPI.swift
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

private struct HTTPHeader {
    static let authorization = "Authorization"
    static let date = "Date"
    static let userAgent = "User-Agent"
    static let platform = "X-Client-Platform"
    static let osVersion = "X-Client-OS-Version"
    static let appVersion = "X-Client-App-Version"
    static let sessionID = "X-Client-Session-ID"
    static let eventIndex = "X-Client-Event-Index"
    static let experimentIDs = "X-Client-Experiment-IDs"
    static let geoLocation = "X-Geo-Location"
    static let firstInstallDeviceID = "X-Client-Install-Device-ID"
}

extension NSMutableURLRequest {

    fileprivate static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // RFC2822 Format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        return dateFormatter
    }()
    
    /// Sets the "Authentication" header appropriately for Victorious API requests. Since the Date and User-Agent headers are
    /// used in calculating the correct Authentication header, this method calculates and sets those, too.
    public func v_setAuthenticationHeader(appID: Int, deviceID: String, buildNumber: String, userID: Int = 0, authenticationToken: String = "") {
        
        let currentDate = NSMutableURLRequest.dateFormatter.string(from: Date())
        setValue(currentDate, forHTTPHeaderField: HTTPHeader.date)
        
        let previousUserAgent = value(forHTTPHeaderField: HTTPHeader.userAgent) ?? "victorious/\(buildNumber)"
        let newUserAgent = "\(previousUserAgent) aid:\(appID) uuid:\(deviceID) build:\(buildNumber)"
        setValue(newUserAgent, forHTTPHeaderField: HTTPHeader.userAgent)
        
        var path: String = ""
        if let url = self.url, let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            path = urlComponents.percentEncodedPath
        }
        let sha1String = "\(currentDate)\(path)\(newUserAgent)\(authenticationToken)\(self.httpMethod)".v_sha1()
        setValue("Basic \(userID):\(sha1String)", forHTTPHeaderField: HTTPHeader.authorization)
    }
    
    /// Sets the value of the "X-Client-Platform" header to a constant value
    /// that has been defined in the Victorious API to identify iOS clients.
    public func v_setPlatformHeader() {
        setValue("iOS", forHTTPHeaderField: HTTPHeader.platform)
    }
    
    /// Sets the value of the "X-Client-Install-Device-ID" header to the locally stored value
    /// If a local value does not exist, we grab the current IDFV and set it
    /// - parameter firstInstallDeviceID: the device ID when the app is installed
    public func v_setIdentiferForVendorHeader(firstInstallDeviceID deviceID: String) {
        setValue(deviceID, forHTTPHeaderField: HTTPHeader.firstInstallDeviceID)
    }
    
#if os(iOS)
    /// Sets the value of the "X-Client-OS-Version" header to the system version
    public func v_setOSVersionHeader() {
        setValue(UIDevice.current.systemVersion, forHTTPHeaderField: HTTPHeader.osVersion)
    }
#endif
    
    /// Sets the value of the "X-Client-App-Version" header
    public func v_setAppVersionHeaderValue(_ appVersion: String) {
        setValue(appVersion, forHTTPHeaderField: HTTPHeader.appVersion)
    }
    
    /// Sets the value of the "X-Client-Session-ID" header
    public func v_setSessionIDHeaderValue(_ sessionID: String) {
        setValue(sessionID, forHTTPHeaderField: HTTPHeader.sessionID)
    }
    
    /// Sets the value of the "X-Client-Event-Index" header.  Used for tracking requests.
    public func v_setEventIndex(_ eventIndex: Int) {
        setValue( String(eventIndex), forHTTPHeaderField: HTTPHeader.eventIndex)
    }
    
    /// Sets the value of the "X-Client-Experiment-IDs" header
    public func v_setExperimentsHeaderValue(_ experimentSettings: String) {
        setValue(experimentSettings, forHTTPHeaderField: HTTPHeader.experimentIDs)
    }
    
    /// Sets the value of the "X-Geo-Location" header
    public func v_setGeoLocationHeader(location: CLLocationCoordinate2D, postalCode: String?) {
        setValue(locationHeaderValue(location: location, postalCode: postalCode), forHTTPHeaderField: HTTPHeader.geoLocation)
    }
    
    fileprivate func locationHeaderValue(location: CLLocationCoordinate2D, postalCode: String?) -> String {
        
        if let postalCode = postalCode {
            return "latitude:\(location.latitude), longitude:\(location.longitude), postal_code:\(postalCode)"
        }
        else {
            return "latitude:\(location.latitude), longitude:\(location.longitude)"
        }
    }
}
