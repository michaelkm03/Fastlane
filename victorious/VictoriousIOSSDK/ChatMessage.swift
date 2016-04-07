//
//  ChatMessage.swift
//  victorious
//
//  Created by Sebastian Nystorm on 23/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/**
 *  A common ground for incoming and outgoing chat messages.
 *  A `ChatMessage` is send over the Forum Event Chain and therefore implements `ForumEvent`.
 */
public protocol ChatMessage: ForumEvent {
    var text: String? { get }
    var contentURL: NSURL? { get }
}
