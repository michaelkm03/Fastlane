//
//  StreamVisibilityTrackingHelper.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation


@objc class StreamVisibilityTrackingHelper {
    
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
                    if let indexPath = collectionView.indexPathForCell(cell), let stream = stream,
                        let streamItem: VStreamItem = stream.streamItems[indexPath.row] as? VStreamItem {
                            let event = StreamCellContext(streamItem: streamItem, stream: stream, fromShelf: false)
                            streamTrackingHelper.onStreamCellDidBecomeVisibleWithCellEvent(event)
                    }
                }
            }
        }
    }
    
    
}