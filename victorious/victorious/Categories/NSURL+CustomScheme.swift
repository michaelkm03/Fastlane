//
//  NSURL+CustomScheme.swift
//  victorious
//
//  Created by Tian Lan on 7/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension NSURL {
    /// Returns the path of a URL without the leading slash
    var pathWithoutLeadingSlash: String? {
        guard let path = self.path where !path.isEmpty else {
            return nil
        }
        
        return path[path.startIndex.successor() ..< path.endIndex]
    }
    
    var isHTTPScheme: Bool {
        return scheme == "http" || scheme == "https"
    }
}
