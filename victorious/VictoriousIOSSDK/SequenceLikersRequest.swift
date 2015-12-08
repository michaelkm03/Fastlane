//
//  SequenceLikersRequest.swift
//  victorious
//
//  Created by Josh Hinman on 11/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Retrieves a list of users who like a specific sequence
public struct SequenceLikersRequest: PaginatorPageable, ResultBasedPageable {
    
    /// Likers will be retrieved for the sequence with this ID
    public let sequenceID: Int64
    public let urlRequest: NSURLRequest
    
    public let paginator: StandardPaginator
    
    public init(sequenceID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        let paginator = StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage)
        self.init(sequenceID: sequenceID, paginator: paginator)
    }
    
    public init( request: SequenceLikersRequest, paginator: StandardPaginator ) {
        self.init( sequenceID: request.sequenceID, paginator: paginator)
    }
    
    private init(sequenceID: Int64, paginator: StandardPaginator) {
        self.sequenceID = sequenceID
        self.paginator = paginator
        
        let url = NSURL(string: "/api/sequence/liked_by_users/\(sequenceID)")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        self.urlRequest = request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [User] {
        
        guard let usersJSON = responseJSON["payload"]["users"].array else {
            throw ResponseParsingError()
        }
        
        return usersJSON.flatMap { User(json: $0) }
    }
}
