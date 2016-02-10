//
//  ContentCellSetupHelper.swift
//  victorious
//
//  Created by Alex Tamoykin on 2/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@objc class ContentCellSetupResult: NSObject {
    let previewView: VSequencePreviewView
    let videoPlayer: VVideoPlayer?

    init(previewView: VSequencePreviewView, videoPlayer: VVideoPlayer? = nil) {
        self.previewView = previewView
        self.videoPlayer = videoPlayer
    }
}

/// Helper class that sets up a contentCell
@objc class ContentCellSetupHelper: NSObject {
    class func setup(contentCell contentCell: VContentCell,
        contentPreviewProvider: VContentPreviewViewProvider,
        contentCellDelegate: VContentCellDelegate,
        detailDelegate: VSequencePreviewViewDetailDelegate,
        videoPreviewViewDelegate: VVideoPreviewViewDelegate,
        adBreak: VAdBreak?) -> ContentCellSetupResult {

            contentCell.minSize = CGSize(width: contentCell.minSize.width, height: VShrinkingContentLayoutMinimumContentHeight)
            contentCell.delegate = contentCellDelegate

            contentPreviewProvider.hasRelinquishedPreviewView = true
            let previewView = contentPreviewProvider.getPreviewView()
            previewView.detailDelegate = detailDelegate

            var videoPlayerToReturn: VVideoPlayer? = nil
            if let videoPreviewView = previewView as? VVideoPreviewView {
                let videoPlayer = videoPreviewView.videoPlayer
                videoPlayerToReturn = videoPlayer
                videoPreviewView.delegate = videoPreviewViewDelegate

                if let receiver = contentCell as? VContentPreviewViewReceiver {
                    receiver.setVideoPlayer(videoPlayer)
                }

                if let adBreak = adBreak {
                    contentCell.playAdWithAdBreak(adBreak)
                } else {
                    videoPlayer.playFromStart()
                }
            }

            return ContentCellSetupResult(previewView: previewView, videoPlayer: videoPlayerToReturn)
    }
}
