//
//  Pageable.swift
//  victorious
//
//  Created by Josh Hinman on 11/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// A special RequestType for endpoints that support pagination
public protocol Pageable: RequestType {
    typealias PageableResultType
    
    func parseResponse( response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON ) throws -> (results: PageableResultType, nextPageRequest: Self?, previousPageRequest: Self?)
}
