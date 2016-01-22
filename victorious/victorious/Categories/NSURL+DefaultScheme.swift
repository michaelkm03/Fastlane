//
//  NSURL+DefaultScheme.swift
//  victorious
//
//  Created by Josh Hinman on 1/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension NSURL {
    
    /// If `string` does not specify a scheme, a URL will be created with the `defaultScheme` added.
    static func v_URLWithString(string: String, defaultScheme: String = "http") -> NSURL? {
        if let components = NSURLComponents(string: string) where components.scheme == nil {
            components.scheme = defaultScheme
            return NSURL(string: addPreceedingSlashesToAuthoritySectionOfURL(components.string) ?? string)
        } else {
            return NSURL(string: string)
        }
    }
}

/// The "authority" section of a URL is the part that includes the username/password, host, and port.
/// RFC 3986 states that the authority section should be proceeded by "//". This function adds it if it's missing.
private func addPreceedingSlashesToAuthoritySectionOfURL(string: String?) -> String? {
    guard let urlString = string,
        let schemeRegex = schemeRegex else {
            return string
    }
    return schemeRegex.stringByReplacingMatchesInString(urlString, options: [], range: NSRange(location: 0, length: urlString.utf16.count), withTemplate: "$1://")
}

/// Matches everything up to and including the ":" in "http:google.com", but only if it isn't followed by "/".
/// (i.e. this regex will NOT match the string "http://google.com")
private let schemeRegex = try? NSRegularExpression(pattern: "(^\\w+?):(?!\\/)", options: [])
