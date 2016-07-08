//
//  NetworkDataSource.swift
//  victorious
//
//  Created by Tian Lan on 5/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Conformers are data sources that fetch `DataObject` from the network
protocol NetworkDataSource: class {
    /// The results fetched from network that should be visible to users
    var visibleItems: [ChatFeedContent] { get }
}
