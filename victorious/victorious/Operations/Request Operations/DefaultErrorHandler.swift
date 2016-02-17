//
//  DefaultErrorHandler.swift
//  victorious
//
//  Created by Patrick Lynch on 2/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A simple implementation that logs each error encountered.
/// Priority is low to allow other more functional error handlers
/// to take precedence.
class DefaultErrorHandler: RequestErrorHandler {
    
    let priority: Int = 0
    
    let requestIdentifier: String
    
    init(requestIdentifier: String) {
        self.requestIdentifier = requestIdentifier
    }
    
    func handleError(error: NSError) -> Bool {
        VLog("RequestOperation `\(requestIdentifier)` failed with error: \(error)")
        return true
    }
}
