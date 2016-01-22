//
//  NSURL+Failable.swift
//  victorious
//
//  Created by Patrick Lynch on 1/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension NSURL {
    
    /// Attempts to initialize a URL from the provided optional string, checking that
    /// the string is defined and that it is not empty, i.e. ""
    convenience init?(vsdk_string string: String?) {
        guard let string = string where !string.characters.isEmpty else {
            return nil
        }
        self.init(string: string)
    }
}
