//
//  StreamCellContext.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class StreamCellContext : NSObject {
    let streamItem: VStreamItem
    let stream: VStream
    var fromShelf = false
    
    init(streamItem: VStreamItem, stream: VStream, fromShelf: Bool) {
        self.streamItem = streamItem
        self.stream = stream
        self.fromShelf = fromShelf
    }
}