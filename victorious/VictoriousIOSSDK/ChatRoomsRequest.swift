//
//  ChatRoomsRequest.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

public struct ChatRoomsRequest: RequestType {
    public var urlRequest: URLRequest

    public init?(apiPath: APIPath) {
        guard let url = apiPath.url else {
            return nil
        }

        self.urlRequest = URLRequest(url: url)
    }

    public func parseResponse(response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> [ChatRoom] {
        guard let chatroomsResponse = responseJSON["payload"]["room_list"].array else {
            throw ResponseParsingError(localizedDescription: "Failed to parse chat rooms response payload")
        }
        return chatroomsResponse.flatMap { ChatRoom(json: $0) }
    }
}
