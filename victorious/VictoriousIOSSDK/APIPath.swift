//
//  APIPath.swift
//  victoriousIOSSDK
//
//  Created by Jarod Long on 6/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A wrapper around a templatized API path which handles macro substitution and query parameters.
public struct APIPath: Equatable {
    // MARK: - Initializing
    
    public init(templatePath: String, macroReplacements: [String: String] = [:], queryParameters: [String: String] = [:]) {
        self.templatePath = templatePath
        self.macroReplacements = macroReplacements
        self.queryParameters = queryParameters
    }
    
    // MARK: - Path information
    
    /// The template API path. May contain macro placeholders.
    public var templatePath: String
    
    /// A mapping of macro placeholders to their replacement strings.
    ///
    /// This must be set before accessing `url` to replace macros properly.
    ///
    public var macroReplacements: [String: String]
    
    /// A set of query parameters to add to the processed URL.
    public var queryParameters: [String: String]
    
    // MARK: - Getting the processed URL
    
    /// The processed URL value with macros replaced and query parameters added.
    public var url: URL? {
        var processedPath = templatePath
        
        if macroReplacements.count > 0 {
            processedPath = VSDKURLMacroReplacement().urlByReplacingMacros(from: macroReplacements, inURLString: processedPath)
        }
        
        if queryParameters.count > 0 {
            if let components = NSURLComponents(string: processedPath) {
                components.queryItems = (components.queryItems ?? []) + queryParameters.map {
                    (URLQueryItem(name: $0, value: $1))
                }
                
                if let pathWithQueryParameters = components.string {
                    processedPath = pathWithQueryParameters
                } else {
                    assertionFailure("Failed to add query parameters to URL.")
                }
            } else {
                assertionFailure("Failed to construct URL components from template URL to add query parameters.")
            }
        }
        
        return URL(string: processedPath)
    }
}

public func ==(lhs: APIPath, rhs: APIPath) -> Bool {
    return (
        lhs.templatePath == rhs.templatePath &&
        lhs.macroReplacements == rhs.macroReplacements &&
        lhs.queryParameters == rhs.queryParameters
    )
}
