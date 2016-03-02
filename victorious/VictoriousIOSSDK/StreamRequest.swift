//
//  StreamRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct StreamRequest: PaginatorPageable, ResultBasedPageable {
    
    public let paginator: StreamPaginator
    public let apiPath: String
    public let sequenceID: String?
    
    public init?( apiPath: String, sequenceID: String?, paginator: StreamPaginator? = nil ) {
        if let paginator = paginator ?? StreamPaginator(apiPath: apiPath, sequenceID: sequenceID) {
            self.init( apiPath: apiPath, sequenceID: sequenceID, paginator: paginator )
        } else {
            return nil
        }
    }
    
    public init( apiPath: String, sequenceID: String?, paginator: StreamPaginator ) {
        self.paginator = paginator
        self.apiPath = apiPath
        self.sequenceID = sequenceID
    }
    
    public init(request: StreamRequest, paginator: StreamPaginator) {
        self.init(apiPath: request.apiPath, sequenceID: request.sequenceID, paginator: paginator)
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL()
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Stream {
        
        let payload = responseJSON["payload"]
        
        let stream: Stream
        
        if payload.array != nil {
            
            // User profile and other streams with `stream_id` in the response
            var dictionary = [ "id" : responseJSON["stream_id"], "items" : payload ]
            dictionary.unionInPlace( dictionaryWithSupplementalValues(responseJSON) )
            
            if let streamFromItems = Stream(json: JSON(dictionary)) {
                stream = streamFromItems
            } else {
                throw ResponseParsingError()
            }
            
        } else if payload["content"].array != nil{
            
            // Liked posts, and other weird responses with no `stream_id` information
            var dictionary = [ "id" : "anonymous:stream", "items" : payload["content"] ]
            dictionary.unionInPlace( dictionaryWithSupplementalValues(responseJSON) )
            
            if let streamFromItems = Stream(json: JSON(dictionary)) {
                
                stream = streamFromItems
            } else {
                throw ResponseParsingError()
            }
            
        } else if var dictionary = payload.dictionary {
            
            // Regular Streams
            dictionary.unionInPlace( dictionaryWithSupplementalValues(responseJSON) )
            if let streamFromObject = Stream(json: JSON(dictionary)) {
                stream = streamFromObject
                
            } else {
                throw ResponseParsingError()
            }
            
        } else {
            throw ResponseParsingError()
        }
        
        return stream
    }
    
    private func dictionaryWithSupplementalValues(responseJSON: JSON) -> [String : JSON] {
        var dictionary = [String : JSON]()
        
        dictionary["apiPath"]              = JSON(stringLiteral: self.apiPath)
        dictionary["shelf_id"]             = responseJSON["shelf_id"]
        dictionary["stream_id"]            = responseJSON["stream_id"]
        dictionary["ugc_post_allowed"]     = responseJSON["ugc_post_allowed"]
        
        return dictionary
    }
}

private extension Dictionary {
    mutating func unionInPlace<S: SequenceType where S.Generator.Element == (Key,Value)>(sequence: S) {
        for (key, value) in sequence {
            self[key] = value
        }
    }
}
