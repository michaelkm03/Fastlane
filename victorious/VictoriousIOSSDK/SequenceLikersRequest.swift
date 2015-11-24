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
public struct SequenceLikersRequest: Pageable {
    
    /// Likers will be retrieved for the sequence with this ID
    public let sequenceID: Int64
    private let paginator: StandardPaginator
    
    public init(sequenceID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init(sequenceID: sequenceID, paginator: StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage))
    }
    
    private init(sequenceID: Int64, paginator: StandardPaginator) {
        self.sequenceID = sequenceID
        self.paginator = paginator
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/sequence/liked_by_users/\(sequenceID)")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: [User], nextPage: SequenceLikersRequest?, previousPage: SequenceLikersRequest?) {
        guard let usersJSON = responseJSON["payload"]["users"].array else {
            throw ResponseParsingError()
        }
        
        let results = usersJSON.flatMap { User(json: $0) }
        let nextPageRequest: SequenceLikersRequest? = usersJSON.count > 0 ? SequenceLikersRequest(sequenceID: sequenceID, paginator: paginator.nextPage) : nil
        let previousPageRequest: SequenceLikersRequest?
        
        if let previousPage = paginator.previousPage {
            previousPageRequest = SequenceLikersRequest(sequenceID: sequenceID, paginator: previousPage)
        } else {
            previousPageRequest = nil
        }
        return (results, nextPageRequest, previousPageRequest)
    }
}
