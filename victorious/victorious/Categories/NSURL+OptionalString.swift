//
//  NSURL+OptionalString.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension NSURL {
    
    /// Allows initialization with an optional string that returns an optional NSURL
    /// if nil or if the default NSURL initialize with non-optional string fails
    /// for any other of the usual reasons.
    convenience init?(v_string string: String?) {
        guard let string = string where !string.characters.isEmpty else {
            self.init(string: "")
            return nil
        }
        self.init(string: string)
    }
}
