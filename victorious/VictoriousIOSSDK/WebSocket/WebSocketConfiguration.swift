//
//  VictoriousWebSocketEndpoint.swift
//  victorious
//
//  Created by Sebastian Nystorm on 15/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/**
 *  This components specifies the WebSocket endpoint and contains all the information needed for opening a WebSocket.
 */
public struct WebSocketConfiguration {
    let endPoint: String
    let port: UInt
    let serviceVersion: String
    let forceDisconnectTimeout: NSTimeInterval
    let appId: String
    
    /// The initial part of the URL without the token appended.
    let baseUrl: NSURL

    init?(endPoint: String, port: UInt, serviceVersion: String, forceDisconnectTimeout: NSTimeInterval, appId: String) {
        self.endPoint = endPoint
        self.port = port
        self.serviceVersion = serviceVersion
        self.forceDisconnectTimeout = forceDisconnectTimeout
        self.appId = appId

        let urlString = "\(endPoint):\(port)"
        guard var url = NSURL(string: urlString) else {
            return nil
        }
        url = url.URLByAppendingPathComponent(serviceVersion)
        url = url.URLByAppendingPathComponent(appId)
        self.baseUrl = url
    }
    
    public func generateUrlFromToken(token: String) -> NSURL {
        return baseUrl.URLByAppendingPathComponent(token)
    }
}

// MARK: - Chat Service Extension
public extension WebSocketConfiguration {
    
    private struct ChatServiceConstants {
        static let chatServiceEndPoint = "ws://ec2-52-53-214-56.us-west-1.compute.amazonaws.com"
        static let chatServicePort: UInt = 8063
        static let chatServiceVersion = "v1"
        static let forceDisconnectTimeout: NSTimeInterval = 5
        static let appId = "1"
    }
    
    /**
     The default configuration for connecting to the Victorious chat service.
     
     - returns: A configuration instance that points to our remote servers.
     */
    public static func makeChatServiceWebSocketConfiguration() -> WebSocketConfiguration {
        let configuration = WebSocketConfiguration(
            endPoint: ChatServiceConstants.chatServiceEndPoint,
            port: ChatServiceConstants.chatServicePort,
            serviceVersion: ChatServiceConstants.chatServiceVersion,
            forceDisconnectTimeout: ChatServiceConstants.forceDisconnectTimeout,
            appId: ChatServiceConstants.appId)
        return configuration!
    }
}

// MARK: - Local Web Socket
public extension WebSocketConfiguration {

    private struct LocalChatServiceConstants {
        static let chatServiceEndPoint = "ws://localhost"
        static let chatServicePort: UInt = 8063
        static let chatServiceVersion = "v1"
        static let forceDisconnectTimeout: NSTimeInterval = 5
        static let appId = "1"
    }

    /**
     A configuration that points to localhost to test out the chat service without the need for a remote server.
     
     - returns: A configuration instance that points to the local machine.
     */
    public static func makeLocalWebSocketConfiguration() -> WebSocketConfiguration {
        let configuration = WebSocketConfiguration(
            endPoint: LocalChatServiceConstants.chatServiceEndPoint,
            port: LocalChatServiceConstants.chatServicePort,
            serviceVersion: LocalChatServiceConstants.chatServiceVersion,
            forceDisconnectTimeout: LocalChatServiceConstants.forceDisconnectTimeout,
            appId: LocalChatServiceConstants.appId)
        return configuration!
    }
}
