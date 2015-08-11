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

    /// This decorator will be used to modify the API request before sending.
    /// Please make sure all the properties therein are set properly
    /// before calling downloadTemplateWithCompletion()
    let requestDecorator = VAPIRequestDecorator()
    
    private let environment: VEnvironment
    private var apiURL: NSURL {
        return NSURL(string: "/api/template", relativeToURL: environment.baseURL)!
    }
    
    init(environment: VEnvironment) {
        self.environment = environment
    }
    
    func downloadTemplateWithCompletion( completion: VTemplateDownloaderCompletion ) {
        let request = NSMutableURLRequest(URL: apiURL)
        requestDecorator.appID = environment.appID
        requestDecorator.updateHeadersInRequest(request)
        
        let urlSession = NSURLSession.sharedSession()
        let dataTask = urlSession.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            completion(data, error)
        }
        dataTask.resume()
    }
}
