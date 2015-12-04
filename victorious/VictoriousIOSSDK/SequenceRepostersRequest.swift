//
//  SequenceRepostersRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct SequenceRepostersRequest: Pageable {
    
    public let urlRequest: NSURLRequest
    
    public let sequenceID: Int64
    
    public let paginator: PaginatorType
    
    public init( request: SequenceRepostersRequest, paginator: PaginatorType ) {
        self.init( sequenceID: request.sequenceID, paginator: paginator )
    }
    
    public init( sequenceID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init(sequenceID: sequenceID, paginator: StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage))
    }
    
    private init(sequenceID: Int64, paginator: PaginatorType) {
        self.sequenceID = sequenceID
        self.paginator = paginator
        
        let url = NSURL(string: "/api/repost/all/\(String(self.sequenceID))")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        self.urlRequest = request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [User] {
        guard let usersJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        return usersJSON.flatMap { User(json: $0) }
    }
}
