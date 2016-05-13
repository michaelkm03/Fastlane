//
//  TemplateDrivenRequestType.swift
//  victorious
//
//  Created by Tian Lan on 5/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Conformers take a full URL string from template and construct a
/// NSURLRequest around it.
public protocol TemplateDrivenRequestType: RequestType {
    
    /// url string we get from template
    var urlString: String { get }
    
    /// A dictionary that represents a mapping from URL Macros to actual content strings
    var macroReplacementDictionary: [String: String]? { get }
}

extension TemplateDrivenRequestType {
    
    /// Default ipmlementation for `baseURL` that is requried by `RequestType`.
    /// This implementation makes sure all template driven requests have the correct base URL
    /// defined in template, and not being replaced with client-side current environment's base URL
    public var baseURL: NSURL? {
        let url = NSURL(string: urlString)
        return url?.baseURL
    }
    
    public var macroReplacementDictionary: [String: String]? {
        return nil
    }
    
    /// Default implementation for `urlRequest` that is required by `RequestType`
    public var urlRequest: NSURLRequest {
        let expandedURLString = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary(macroReplacementDictionary, inURLString: urlString)
        
        guard let url = NSURL(string: expandedURLString) else {
            // This failure means that template has provided us bad endpoint URL. We will break debug builds to catch that,
            // and return an empty `NSURL` object so that the request will return empty results to the caller
            assertionFailure("Unable to construct an `NSURL` with the urlString provided: \(expandedURLString)")
            return NSURLRequest(URL: NSURL())
        }
        
        return NSURLRequest(URL: url)
    }
}
