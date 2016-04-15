//
//  FetchWebContentOperation.swift
//  victorious
//
//  Created by Jarod Long on 4/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A type of operation that fetches HTML from a remote location. Intended to be subclassed.
class FetchWebContentOperation: RemoteFetcherOperation {
    /// The fetched HTML that should be set after the operation completes.
    var resultHTMLString: String?
    
    /// The URL that relative links in the result HTML are resolved from. Must be overridden by subclasses.
    var publicBaseURL: NSURL {
        assertionFailure("FetchWebContentOperation subclass must override publicBaseURL property.")
        return NSURL()
    }
}
