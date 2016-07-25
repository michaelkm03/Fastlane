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
    
    /// Asks the receiver to handle the error provided.
    /// - returns `true` if the error could be handed by the receiver, and `false` if it was not possible.
    func handle(error: NSError, with request: NSURLRequest?) -> Bool
}
