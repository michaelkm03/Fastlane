//
//  StreamVisibilityTrackingHelper.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation


@objc class ShelfVisibilityTrackingHelper {
    
    var stream: VStream?
    var trackingMinRequiredCellVisibilityRatio: CGFloat = 0.0
    
    private var collectionView: UICollectionView
    private var streamTrackingHelper = VStreamTrackingHelper()
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    func trackVisibleSequences() {
        let streamVisibleRect = collectionView.bounds;
        if let visibleCells = collectionView.visibleCells() as? [UICollectionViewCell] {
            for cell in visibleCells {
                let intersection = streamVisibleRect.rectByIntersecting(cell.frame)
                let visibleWidthRatio = intersection.width / cell.frame.width
                let visibleHeightRatio = intersection.height / cell.frame.height
                let roundedRatio = ceil(visibleWidthRatio * 100 + visibleHeightRatio * 100) / 200
                if roundedRatio >= trackingMinRequiredCellVisibilityRatio {
                    if let indexPath = collectionView.indexPathForCell(cell), let stream = stream {
                        
                        let streamItem: VStreamItem? = stream.streamItems[indexPath.row] as? VStreamItem
                        
                        // If this stream item is a stream, track the first sequence
                        if let stream = streamItem as? VStream {
                            if let firstSequence = stream.streamItems.firstObject as? VSequence {
                                let event = StreamCellContext(streamItem: firstSequence, stream: stream, fromShelf: false)
                                streamTrackingHelper.onStreamCellDidBecomeVisibleWithCellEvent(event)
                            }
                        }
                        else if let sequence = streamItem {
                            let event = StreamCellContext(streamItem: sequence, stream: stream, fromShelf: false)
                            streamTrackingHelper.onStreamCellDidBecomeVisibleWithCellEvent(event)
                        }
                    }
                }
            }
        }
    }
}
