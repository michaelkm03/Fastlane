
//
//  SequenceUserInteractionsRequest
//  victorious
//
//  Created by Michael Sena on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON

public struct SequenceUserInteractionsRequest: RequestType {
    
    public let sequenceID: String
    public let userID: Int64
    
    public init(sequenceID: String, userID: Int64) {
        self.sequenceID = sequenceID
        self.userID = userID
    }
    
    public var urlRequest: NSURLRequest {
        let basePath = NSURL(string: "/api/sequence/users_interactions")!
        let fullURL = basePath.URLByAppendingPathComponent(String(self.sequenceID)).URLByAppendingPathComponent(String(self.userID))
        return NSURLRequest(URL: fullURL)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Bool {
        guard let has_repostedBool = responseJSON["payload"]["has_reposted"].bool else {
            throw ResponseParsingError()
        }
        return has_repostedBool
    }
    
}
