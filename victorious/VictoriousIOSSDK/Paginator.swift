//
//  Paginator.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public protocol Paginator {
    
    /// Returns a Paginator object that contains data for retrieving the next page
    /// of paginated data after the receiver.
    func previousPage() -> Self?
    
    /// Returns a Paginator object that contains data for retrieving the next page
    /// of paginated data after the receiver.
    func nextPage() -> Self?
    
    /// Modifies the provided request by adding pagination data to it according to
    /// the implementation-specific logic for doing so.
    func addPaginationArgumentsToRequest(request: NSMutableURLRequest)
}