//
//  DebugErrorHandler.swift
//  victorious
//
//  Created by Patrick Lynch on 2/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A simple implementation that logs each error encountered.
/// Priority is low to allow other more functional error handlers
/// to take precedence.
class DebugErrorHandler: RequestErrorHandler {
    
    let requestIdentifier: String
    
    init(requestIdentifier: String) {
        self.requestIdentifier = requestIdentifier
    }
    
    func handle(_ error: NSError, with request: URLRequest? = nil) -> Bool {
        Log.warning("FetcherOperation `\(requestIdentifier)` failed with error: \(error) for request -> \(request)")
        
        // Doesn't actually handle errors, just logs them.
        return false
    }
}
