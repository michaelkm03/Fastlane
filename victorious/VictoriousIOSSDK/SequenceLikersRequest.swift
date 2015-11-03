//
//  SequenceLikersRequest.swift
//  victorious
//
//  Created by Josh Hinman on 11/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct SequenceLikersRequest: Pageable {
    /// Likers will be retrieved for the sequence with this ID
    public let sequenceID: Int64
    
    public init(sequenceID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.sequenceID = sequenceID
        self.paginator = StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage)
    }
    
    private let paginator: StandardPaginator
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/sequence/liked_by_users/\(sequenceID)")!
        return NSURLRequest(URL: url)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: [User], nextPageRequest: SequenceLikersRequest?, previousPageRequest: SequenceLikersRequest?) {
        if let usersJSON = responseJSON["payload"]["users"].array {
            return ([], nil, nil) //(usersJSON.flatMap { User(json: $0) }, nil, nil)
        }
        throw ResponseParsingError()
    }
}
