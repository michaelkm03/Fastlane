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

@objc class ContentCellSetupHelper: NSObject {
    /// Setup a contentCell with the existing preview view provider
    /// - parameter contentCell: content cell to be set up
    /// - parameter previewViewProvider: provider of an existing preview view
    /// - parameter adDelegate: ad depegate for a content cell
    /// - parameter detailDelegate: detailDelegate to be set on a preview view
    /// - parameter videoPreviewViewDelegate: for a video player in case a cell is a video cell
    /// - parameter adBreak: presense of an adBreak will trigger playing of the ads instead of playing content
    func setup(contentCell contentCell: VContentCell,
        previewViewProvider: VContentPreviewViewProvider,
        adDelegate: AdLifecycleDelegate,
        detailDelegate: VSequencePreviewViewDetailDelegate,
        videoPreviewViewDelegate: VVideoPreviewViewDelegate,
        adBreak: VAdBreak?) -> ContentCellSetupResult {

            return executeSetup(contentCell: contentCell,
                previewViewProvider: previewViewProvider,
                adDelegate: adDelegate,
                detailDelegate: detailDelegate,
                videoPreviewViewDelegate: videoPreviewViewDelegate,
                adBreak: adBreak,
                sequence: nil,
                dependencyManager: nil)
    }

    /// Setup a contentCell without an existing preview provider.
    /// A new preview view will be created.
    /// - parameter contentCell: content cell to be set up
    /// - parameter adDelegate: ad depegate for a content cell
    /// - parameter detailDelegate: detailDelegate to be set on a preview view
    /// - parameter videoPreviewViewDelegate: for a video player in case a cell is a video cell
    /// - parameter adBreak: presense of an adBreak will trigger playing of the ads instead of playing content
    /// - parameter sequence: a sequence used to initialize a new preview view
    /// - parameter dependencyManager: a dependencyManager used to initialize a new preview view
    func setup(contentCell contentCell: VContentCell,
        adDelegate: AdLifecycleDelegate,
        detailDelegate: VSequencePreviewViewDetailDelegate,
        videoPreviewViewDelegate: VVideoPreviewViewDelegate,
        adBreak: VAdBreak?,
        sequence: VSequence,
        dependencyManager: VDependencyManager) -> ContentCellSetupResult {

            return executeSetup(contentCell: contentCell,
                previewViewProvider: nil,
                adDelegate: adDelegate,
                detailDelegate: detailDelegate,
                videoPreviewViewDelegate: videoPreviewViewDelegate,
                adBreak: adBreak,
                sequence: sequence,
                dependencyManager: dependencyManager)
    }

    private func executeSetup(contentCell contentCell: VContentCell,
        previewViewProvider: VContentPreviewViewProvider?,
        adDelegate: AdLifecycleDelegate,
        detailDelegate: VSequencePreviewViewDetailDelegate,
        videoPreviewViewDelegate: VVideoPreviewViewDelegate,
        adBreak: VAdBreak?,
        sequence: VSequence?,
        dependencyManager: VDependencyManager?) -> ContentCellSetupResult {

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
