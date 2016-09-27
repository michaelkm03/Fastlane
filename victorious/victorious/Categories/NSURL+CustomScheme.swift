//
//  NSURL+CustomScheme.swift
//  victorious
//
//  Created by Tian Lan on 7/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension URL {
    /// Returns the path of a URL without the leading slash
    var pathWithoutLeadingSlash: String? {
        guard let path = self.path , !path.isEmpty else {
            return nil
        }
        
        return path[path.characters.index(after: path.startIndex) ..< path.endIndex]
    }
    
    var isHTTPScheme: Bool {
        return scheme == "http" || scheme == "https"
    }
}
