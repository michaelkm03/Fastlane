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
    static let experimentIDs = "X-Client-Experiment-IDs"
    static let geoLocation = "X-Geo-Location"
}

extension NSMutableURLRequest {

    private static let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // RFC2822 Format
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
        return dateFormatter
    }()
    
    /// Sets the "Authentication" header appropriately for Victorious API requests. Since the Date and User-Agent headers are
    /// used in calculating the correct Authentication header, this method calculates and sets those, too.
    public func v_setAuthenticationHeader(#appID: Int, deviceID: String, buildNumber: String, userID: Int = 0, authenticationToken: String = "") {
        
        let currentDate = NSMutableURLRequest.dateFormatter.stringFromDate(NSDate())
        setValue(currentDate, forHTTPHeaderField: HTTPHeader.date)
        
        let previousUserAgent = valueForHTTPHeaderField(HTTPHeader.userAgent) ?? "victorious/\(buildNumber)"
        let newUserAgent = "\(previousUserAgent) aid:\(appID) uuid:\(deviceID) build:\(buildNumber)"
        setValue(newUserAgent, forHTTPHeaderField: HTTPHeader.userAgent)
        
        var path: String = ""
        if let URL = self.URL,
           let urlComponents = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true),
           let percentEncodedPath = urlComponents.percentEncodedPath {
            path = percentEncodedPath
        }
        let sha1String = "\(currentDate)\(path)\(newUserAgent)\(authenticationToken)\(self.HTTPMethod)".v_sha1()
        setValue("Basic \(userID):\(sha1String)", forHTTPHeaderField: HTTPHeader.authorization)
    }
    
    /// Sets the value of the "X-Client-Platform" header to a constant value
    /// that has been defined in the Victorious API to identify iOS clients.
    public func v_setPlatformHeader() {
        setValue("iOS", forHTTPHeaderField: HTTPHeader.platform)
    }
    
#if os(iOS)
    /// Sets the value of the "X-Client-OS-Version" header to the system version
    public func v_setOSVersionHeader() {
        setValue(UIDevice.currentDevice().systemVersion, forHTTPHeaderField: HTTPHeader.osVersion)
    }
#endif
    
    /// Sets the value of the "X-Client-App-Version" header
    public func v_setAppVersionHeaderValue(appVersion: String) {
        setValue(appVersion, forHTTPHeaderField: HTTPHeader.appVersion)
    }

    /// Sets the value of the "X-Client-Session-ID" header
    public func v_setSessionIDHeaderValue(sessionID: String) {
        setValue(sessionID, forHTTPHeaderField: HTTPHeader.sessionID)
    }
    
    /// Sets the value of the "X-Client-Experiment-IDs" header
    public func v_setExperimentsHeaderValue(experimentSettings: String) {
        setValue(experimentSettings, forHTTPHeaderField: HTTPHeader.experimentIDs)
    }
    
    /// Sets the value of the "X-Geo-Location" header
    public func v_setGeoLocationHeader(#location: CLLocationCoordinate2D, postalCode: String?) {
        setValue(locationHeaderValue(location: location, postalCode: postalCode), forHTTPHeaderField: HTTPHeader.geoLocation)
    }
    
    private func locationHeaderValue(#location: CLLocationCoordinate2D, postalCode: String?) -> String {
        
        if let postalCode = postalCode {
            return "latitude:\(location.latitude), longitude:\(location.longitude), postal_code:\(postalCode)"
        }
        else {
            return "latitude:\(location.latitude), longitude:\(location.longitude)"
        }
    }
}