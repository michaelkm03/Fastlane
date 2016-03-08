//
//  SequenceRepostersRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct SequenceRepostersRequest: PaginatorPageable, ResultBasedPageable {
    
    public let urlRequest: NSURLRequest
    
    public let sequenceID: String
    
    public let paginator: StandardPaginator
    
    public init(request: SequenceRepostersRequest, paginator: StandardPaginator ) {
        self.init( sequenceID: request.sequenceID, paginator: paginator )
    }
    
    public init(sequenceID: String, paginator: StandardPaginator = StandardPaginator() ) {
        self.sequenceID = sequenceID
        self.paginator = paginator
        
        let url = NSURL(string: "/api/repost/all/\(self.sequenceID)")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        urlRequest = request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [User] {
        guard let usersJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return usersJSON.flatMap { User(json: $0) }
    }
}
