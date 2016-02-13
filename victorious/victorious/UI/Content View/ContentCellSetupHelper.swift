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
    let contentCell: VContentCell
    let previewViewProvider: VContentPreviewViewProvider?
    let adDelegate: AdLifecycleDelegate
    let detailDelegate: VSequencePreviewViewDetailDelegate
    let videoPreviewViewDelegate: VVideoPreviewViewDelegate
    let adBreak: VAdBreak?
    let sequence: VSequence?
    let dependencyManager: VDependencyManager?

    /// Initialize a new instance of a class with the existing preview view provider
    /// - parameter contentCell: content cell to be set up
    /// - parameter previewViewProvider: provider of an existing preview view
    /// - parameter adDelegate: ad depegate for a content cell
    /// - parameter detailDelegate: detailDelegate to be set on a preview view
    /// - parameter videoPreviewViewDelegate: for a video player in case a cell is a video cell
    /// - parameter adBreak: presense of an adBreak will trigger playing of the ads instead of playing content
    init(contentCell: VContentCell,
        previewViewProvider: VContentPreviewViewProvider,
        adDelegate: AdLifecycleDelegate,
        detailDelegate: VSequencePreviewViewDetailDelegate,
        videoPreviewViewDelegate: VVideoPreviewViewDelegate,
        adBreak: VAdBreak?) {
            self.contentCell = contentCell
            self.previewViewProvider = previewViewProvider
            self.adDelegate = adDelegate
            self.detailDelegate = detailDelegate
            self.videoPreviewViewDelegate = videoPreviewViewDelegate
            self.adBreak = adBreak
            self.sequence = nil
            self.dependencyManager = nil
    }

    /// Initialize a new instance of a class without an existing preview provider. 
    /// A new preview view will be created.
    /// - parameter contentCell: content cell to be set up
    /// - parameter adDelegate: ad depegate for a content cell
    /// - parameter detailDelegate: detailDelegate to be set on a preview view
    /// - parameter videoPreviewViewDelegate: for a video player in case a cell is a video cell
    /// - parameter adBreak: presense of an adBreak will trigger playing of the ads instead of playing content
    /// - parameter sequence: a sequence used to initialize a new preview view
    /// - parameter dependencyManager: a dependencyManager used to initialize a new preview view
    init(contentCell: VContentCell,
        adDelegate: AdLifecycleDelegate,
        detailDelegate: VSequencePreviewViewDetailDelegate,
        videoPreviewViewDelegate: VVideoPreviewViewDelegate,
        adBreak: VAdBreak?,
        sequence: VSequence,
        dependencyManager: VDependencyManager) {
            self.contentCell = contentCell
            self.previewViewProvider = nil
            self.adDelegate = adDelegate
            self.detailDelegate = detailDelegate
            self.videoPreviewViewDelegate = videoPreviewViewDelegate
            self.adBreak = adBreak
            self.sequence = sequence
            self.dependencyManager = dependencyManager
    }

    /// Setup a new content cell and return a result
    /// - returns: An new instance of `ContentCellSetupResult`
    var result: ContentCellSetupResult {
        contentCell.minSize = CGSize(width: contentCell.minSize.width, height: VShrinkingContentLayoutMinimumContentHeight)
        contentCell.delegate = adDelegate
        previewViewProvider?.hasRelinquishedPreviewView = true
        let receiver = contentCell as? VContentPreviewViewReceiver

        let previewView: VSequencePreviewView
        if let existingPreviewView = previewViewProvider?.getPreviewView() {
            previewView = existingPreviewView
        } else {
            guard let sequence = sequence, receiver = receiver, dependencyManager = dependencyManager else {
                fatalError("Can't create a seqeunce preview view without sequence, receiver and dependency manager")
            }
            previewView = createPreviewView(sequence: sequence, receiver: receiver, dependencyManager: dependencyManager)
        }

        previewView.detailDelegate = detailDelegate

        var videoPlayerToReturn: VVideoPlayer? = nil
        if let videoPreviewView = previewView as? VVideoPreviewView {
            let videoPlayer = videoPreviewView.videoPlayer
            videoPlayerToReturn = videoPlayer
            videoPreviewView.delegate = videoPreviewViewDelegate
            receiver?.setVideoPlayer(videoPlayer)
            if let adBreak = adBreak {
                contentCell.playAdWithAdBreak(adBreak)
            } else {
                videoPlayer.playFromStart()
            }
        }

        return ContentCellSetupResult(previewView: previewView, videoPlayer: videoPlayerToReturn)
    }

    private func createPreviewView(sequence sequence: VSequence, receiver: VContentPreviewViewReceiver, dependencyManager: VDependencyManager) -> VSequencePreviewView {
        let superview = receiver.getTargetSuperview()
        let previewView = VSequencePreviewView(sequence: sequence,
            streamItem: sequence,
            frame: superview.bounds,
            dependencyManager: dependencyManager,
            focusType: VFocusType.Detail)
        superview.addSubview(previewView)
        superview.v_addFitToParentConstraintsToSubview(previewView)
        return previewView
    }
}
