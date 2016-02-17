//
//  RequestErrorHandler.swift
//  victorious
//
//  Created by Patrick Lynch on 2/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Defines an object that can be asked to handle errors.
protocol RequestErrorHandler {
    
    /// Used to sort error handlers before asking one of a group of error handlers
    /// to handle an error.  Consumers of `RequestErrorHandler` are designed to
    /// call `handleError` for only the handler with the highest-ranking priority.
    var priority: Int { get }
    
    /// Asks the receiver to handle the error provided.
    /// - returns `true` if the error could be handed by the receiver, and `false` if it was not possible.
    func handleError( error: NSError ) -> Bool
}
