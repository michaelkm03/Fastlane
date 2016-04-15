//
//  TemplateNetworkSource.swift
//  victorious
//
//  Created by Sebastian Nystorm on 22/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public protocol NetworkSource: ForumEventReceiver, ForumEventSender {
    /**
     Allows for adding child receivers from an external source.
     
     - parameter receiver: The receiver of `ForumEvent`.
     */
    func addChildReceiver(receiver: ForumEventReceiver)
    
    /**
     The receiver will prepare any connections and make sure it is ready to be used.
     */
    func setUp()
    
    /**
     The receiver will close any connections open and clean up after itself.
     */
    func tearDown()
}

public protocol NetworkSourceWebSocket: NetworkSource {
    
    /// A flag that tells if the connection is open and ready to use.
    var isConnected: Bool { get }
    
    /// Replaces the endPoint used for opening a WebSocket connection. This URL has the use once token baked into it.
    ///- parameter endPoint: The actual URL to hit in the form: "ws:// or wss://"
    ///
    func replaceEndPoint(endPoint: NSURL)
}
