//
//  HashtagResponseParser.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON

/// A struct used to parse a list of hashtag objects from the server's JSON data
public struct HashtagResponseParser {
    public func parseResponse(responseJSON: JSON) throws -> [Hashtag] {
        guard let hashtagJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return hashtagJSON.flatMap { Hashtag(json: $0) }
    }
}
