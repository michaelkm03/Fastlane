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
    
    public let sequenceID: Int64
    private let paginator: StandardPaginator
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/repost/all/\(String(self.sequenceID))")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public init( sequenceID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init(sequenceID: sequenceID, paginator: StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage))
    }
    
    private init(sequenceID: Int64, paginator: StandardPaginator) {
        self.sequenceID = sequenceID
        self.paginator = paginator
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: [User], nextPage: SequenceRepostersRequest?, previousPage: SequenceRepostersRequest?) {
        guard let usersJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        let results = usersJSON.flatMap { User(json: $0) }
        let nextPageRequest: SequenceRepostersRequest? = !usersJSON.isEmpty ? SequenceRepostersRequest(sequenceID: sequenceID, paginator: paginator.nextPage) : nil
        let previousPageRequest: SequenceRepostersRequest?
        
        if let previousPage = paginator.previousPage {
            previousPageRequest = SequenceRepostersRequest(sequenceID: sequenceID, paginator: previousPage)
        } else {
            previousPageRequest = nil
        }
        return (results, nextPageRequest, previousPageRequest)
    }
}
