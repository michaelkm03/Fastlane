//
//  SequenceLikersRequest.swift
//  victorious
//
//  Created by Josh Hinman on 11/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Retrieves a list of users who like a specific sequence
public struct SequenceLikersRequest: PaginatorPageable, ResultBasedPageable {
    
    /// Likers will be retrieved for the sequence with this ID
    public let sequenceID: String
    public let urlRequest: NSURLRequest
    
    public let paginator: StandardPaginator
    
    public init(request: SequenceLikersRequest, paginator: StandardPaginator ) {
        self.init( sequenceID: request.sequenceID, paginator: paginator )
    }
    
    public init(sequenceID: String, paginator: StandardPaginator = StandardPaginator() ) {
        self.sequenceID = sequenceID
        self.paginator = paginator
        
        let url = NSURL(string: "/api/sequence/liked_by_users/\(sequenceID)")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        self.urlRequest = request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [User] {
        
        guard let usersJSON = responseJSON["payload"]["users"].array ?? responseJSON["payload"].array  else {
            throw ResponseParsingError()
        }
        
        return usersJSON.flatMap { User(json: $0) }
    }
}
