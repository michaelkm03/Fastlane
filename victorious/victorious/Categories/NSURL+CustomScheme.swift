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
    func pathWithoutLeadingSlash() -> String? {
        guard var path = self.path else {
            return nil
        }
        
        path.removeAtIndex(path.startIndex)
        return path
    }
}
