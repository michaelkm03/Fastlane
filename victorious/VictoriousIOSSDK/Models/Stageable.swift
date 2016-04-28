//
//  Stageable.swift
//  victorious
//
//  Created by Sebastian Nystorm on 18/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public protocol Stageable {
    var url: NSURL { get }
    var contentType: ContentType { get }
}
