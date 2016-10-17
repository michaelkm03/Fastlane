//
//  WebSocketController.swift
//  victorious
//
//  Created by Sebastian Nystorm on 13/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public class WebSocketController {

    // MARK: - EVENT BLOCKS

    private let onConnect = {
        print("connected")
    }

    private let onDisconnect = { (error: NSError?)
        print("onDisconnect -> \(error)")
    }

    private let onText = { (text: String)
        print("onText -> \(text)")
    }

    private let onData = { (data: Data)
        print("onData count -> \(data.count)")
    }

    // TODO: onPong needed?

    // MARK: - Initialization

    init(with configuration: WebSocketConfiguration) {
        self.configuration = configuration

        webSocketConnection = WebSocket(url: <#T##URL#>, writeQueueQOS: <#T##QualityOfService#>)

    }


    // MARK: - Private vars

    /// Custom background queue dedicated to sending and listening to WebSocket events.
    private lazy var socketListenerQueue: DispatchQueue = {
        DispatchQueue(label: "com.victorious.socket_listener")
    }()

    /// A reference to the instance which has the actual network connection.
    private let webSocketConnection: WebSocket

    /// The config struct used to setup the connection.
    private let configuration: WebSocketConfiguration



}




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
