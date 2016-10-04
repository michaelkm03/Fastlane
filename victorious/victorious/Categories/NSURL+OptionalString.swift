//
//  NSURL+OptionalString.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension URL {
    
    /// Allows initialization with an optional string that returns an optional NSURL
    /// if nil or if the default NSURL initialize with non-optional string fails
    /// for any other of the usual reasons.
    init?(v_string string: String?) {
        guard let string = string , !string.characters.isEmpty else {
            return nil
        }
        self.init(string: string)
    }
}
