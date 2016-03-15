//
//  BasicTemplateDownloader.swift
//  victorious
//
//  Created by Josh Hinman on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Cocoa
import VictoriousCommon

/// A straightforward implementation of VTemplateDownloader
class BasicTemplateDownloader: NSObject, VTemplateDownloader {

    private let environment: VEnvironment
    private let deviceID: String
    private let buildNumber: String
    private let versionNumber: String
    private var apiURL: NSURL {
        return NSURL(string: "/api/template", relativeToURL: environment.baseURL)!
    }
    
    init(environment: VEnvironment, deviceID: String, buildNumber: String, versionNumber: String) {
        self.environment = environment
        self.deviceID = deviceID
        self.buildNumber = buildNumber
        self.versionNumber = versionNumber
    }
    
    func downloadTemplateWithCompletion( completion: VTemplateDownloaderCompletion ) {
        let request = NSMutableURLRequest(URL: apiURL)
        request.v_setAuthenticationHeader(appID: environment.appID.integerValue, deviceID: deviceID, buildNumber: buildNumber)
        request.v_setAppVersionHeaderValue(versionNumber)
        request.v_setPlatformHeader()
        
        let urlSession = NSURLSession.sharedSession()
        let dataTask = urlSession.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            completion(data, error)
        }
        dataTask.resume()
    }
}
