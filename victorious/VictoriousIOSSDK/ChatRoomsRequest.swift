//
//  ChatRoomsRequest.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

public struct ChatRoomsRequest: RequestType {
    public var urlRequest: NSURLRequest

    public init?(apiPath: APIPath) {
        guard let url = apiPath.url else {
            return nil
        }

        self.urlRequest = NSURLRequest(URL: url)
    }

    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [ChatRoom] {
        guard let chatroomsResponse = responseJSON["payload"]["chatrooms"].array else {
            throw ResponseParsingError(localizedDescription: "Failed to parse chat rooms response payload")
        }
        return chatroomsResponse.flatMap { ChatRoom(json: $0) }
    }
}
