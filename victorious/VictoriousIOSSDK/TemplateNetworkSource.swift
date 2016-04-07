//
//  TemplateNetworkSource.swift
//  victorious
//
//  Created by Sebastian Nystorm on 22/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public protocol TemplateNetworkSource: class, ForumEventReceiver, ForumEventSender {
    /// A flag that tells if the connection is open and ready to use.
    var isConnected: Bool { get }

    /**
     Allows for adding child receivers from an external source.
    
     - parameter receiver: The receiver of `ForumEvent`.
    */
    func addChildReceiver(receiver: ForumEventReceiver)
    
    /**
        Replaces the current token used for connecting to the backend.
     
        - parameter token: A use once only token.
     */
    func replaceToken(token: String)
    
    /**
        The receiver will prepare the connection and make sure it is ready to be used.
     */
    func connect()
    
    /**
        The receiver will close the connection and cleanup after it self.
     */
    func disconnect()
}
