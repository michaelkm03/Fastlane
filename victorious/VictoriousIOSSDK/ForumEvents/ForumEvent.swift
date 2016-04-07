//
//  ForumEvent.swift
//  victorious
//
//  Created by Sebastian Nystorm on 23/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/**
 *  This protocol defines the very barebone for being passed along in the Forum Event Chain.
 */
public protocol ForumEvent {
    var timestamp: NSDate { get }
}
