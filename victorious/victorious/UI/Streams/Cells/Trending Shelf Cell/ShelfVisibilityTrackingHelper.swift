//
//  ShelfVisibilityTrackingHelper.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class ShelfVisibilityTrackingHelper {
    
    var shelf: Shelf?
    var trackingMinRequiredCellVisibilityRatio: CGFloat = 0.0
    
    private var collectionView: UICollectionView
    private var streamTrackingHelper = VStreamTrackingHelper()
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    func trackVisibleSequences() {
        let streamVisibleRect = collectionView.bounds;
        for cell in collectionView.visibleCells() {
            let intersection = streamVisibleRect.intersect(cell.frame)
            let visibleWidthRatio = intersection.width / cell.frame.width
            let visibleHeightRatio = intersection.height / cell.frame.height
            let visibleContentRatio = visibleWidthRatio * visibleHeightRatio
            if visibleContentRatio >= trackingMinRequiredCellVisibilityRatio {
                guard let indexPath = collectionView.indexPathForCell(cell),
                       let shelf = shelf else {
                    return
                }
                
                let streamItem = shelf.streamItems[indexPath.row]
                
                // If this shelf item is a stream, track the first sequence
                if let stream = streamItem as? VStream {
                    if let firstSequence = stream.streamItems.first as? VSequence {
                        let event = StreamCellContext(streamItem: firstSequence, stream: shelf, fromShelf: false)
                        streamTrackingHelper.onStreamCellDidBecomeVisibleWithCellEvent(event)
                    }
                    
                } else {
                    let event = StreamCellContext(streamItem: streamItem, stream: shelf, fromShelf: false)
                    streamTrackingHelper.onStreamCellDidBecomeVisibleWithCellEvent(event)
                }
            }
        }
    }
}
