//
//  StreamCellContext.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// Class for containing info about the context in which a certain
/// stream cell was viewed or clicked
class StreamCellContext: NSObject {
    let streamItem: VStreamItem
    let stream: VStream
    var fromShelf = false
    var collectionView: UICollectionView?
    var indexPath: NSIndexPath?
    
    init(streamItem: VStreamItem, stream: VStream, fromShelf: Bool) {
        self.streamItem = streamItem
        self.stream = stream
        self.fromShelf = fromShelf
    }
}
