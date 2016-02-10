//
//  ContentCellSetupHelper.swift
//  victorious
//
//  Created by Alex Tamoykin on 2/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// Helper class that sets up a contentCell
@objc class ContentCellSetupHelper: NSObject {
    class func setup(contentCell contentCell: VContentCell,
        contentPreviewProvider: VContentPreviewViewProvider,
        contentCellDelegate: VContentCellDelegate,
        detailDelegate: VSequencePreviewViewDetailDelegate,
        videoPreviewViewDelegate: VVideoPreviewViewDelegate,
        adBreak: VAdBreak?) -> VSequencePreviewView {

            contentCell.minSize = CGSize(width: contentCell.minSize.width, height: VShrinkingContentLayoutMinimumContentHeight)
            contentCell.delegate = contentCellDelegate

            contentPreviewProvider.hasRelinquishedPreviewView = true
            let previewView = contentPreviewProvider.getPreviewView()
            previewView.detailDelegate = detailDelegate

            if let videoPreviewView = previewView as? VVideoPreviewView {
                let videoPlayer = videoPreviewView.videoPlayer
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

            return previewView
    }
}
