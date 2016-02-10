//
//  ContentCellSetupHelperTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 2/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class TestContentVideoPreviewViewProvider: NSObject, VContentPreviewViewProvider {
    let videoPlayer: VVideoPlayer
    let containerView: UIView
    let restorePreviewView: UIView
    var hasRelinquishedPreviewView = false

    init(videoPlayer: VVideoPlayer, containterView: UIView = UIView(), restorePreviewView: UIView = UIView()) {
        self.videoPlayer = videoPlayer
        self.containerView = containterView
        self.restorePreviewView = restorePreviewView
        super.init()
    }

    func getPreviewView() -> VSequencePreviewView {
        let videoPreviewView = VVideoSequencePreviewView()
        videoPreviewView.videoPlayer = videoPlayer
        return videoPreviewView
    }

    func restorePreviewView(previewView: VSequencePreviewView) {
    }

    func getContainerView() -> UIView {
        return containerView
    }
}

class TestContentCellDelegate: NSObject, VContentCellDelegate {
    var contentCellDidEndPlayingAdCallCount = 0
    var contentCellDidStartPlayingAdCallCount = 0

    func contentCellDidEndPlayingAd(cell: VContentCell!) {
        contentCellDidEndPlayingAdCallCount += 1
    }

    func contentCellDidStartPlayingAd(cell: VContentCell!) {
        contentCellDidStartPlayingAdCallCount += 1
    }
}

class TestDetailDelegate: NSObject, VSequencePreviewViewDetailDelegate {
    var didSelectMediaURLCallCount = 0
    var didLikeSequenceCallCount = 0

    func previewView(previewView: VSequencePreviewView, didSelectMediaURL mediaURL: NSURL, previewImage: UIImage, isVideo: Bool, sourceView: UIView) {
        didSelectMediaURLCallCount += 1
    }

    func previewView(previewView: VSequencePreviewView, didLikeSequence sequence: VSequence, completion: ((Bool) -> Void)?) {
        didLikeSequenceCallCount += 1
    }
}

class TestVideoPreviewViewDelegate: NSObject, VVideoPreviewViewDelegate {
    var animateAlongsideVideoToolbarWillAppearCallCount = 0
    var animateAlongsideVideoToolbarWillDisappearCallCount = 0
    var videoPlaybackDidFinishCallCount = 0

    func animateAlongsideVideoToolbarWillAppear() {
        animateAlongsideVideoToolbarWillAppearCallCount += 1
    }

    func animateAlongsideVideoToolbarWillDisappear() {
        animateAlongsideVideoToolbarWillDisappearCallCount += 1
    }

    func videoPlaybackDidFinish() {
        videoPlaybackDidFinishCallCount += 1
    }
}

class ContentCellSetupHelperTests: BasePersistentStoreTestCase {
    var testVideoPlayer: TestVideoPlayer!
    var testContentCellDelegate: TestContentCellDelegate!
    var testDetailDelegate: TestDetailDelegate!
    var testVideoPreviewViewDelegate: TestVideoPreviewViewDelegate!
    var previewViewProvider: TestContentVideoPreviewViewProvider!
    var contentCell: VContentCell!

    override func setUp() {
        super.setUp()
        testVideoPlayer = TestVideoPlayer()
        testContentCellDelegate = TestContentCellDelegate()
        testDetailDelegate = TestDetailDelegate()
        testVideoPreviewViewDelegate = TestVideoPreviewViewDelegate()
        previewViewProvider = TestContentVideoPreviewViewProvider(videoPlayer: testVideoPlayer)
        contentCell = VContentCell()
    }

    func testPlayingAd() {
        let adBreak = persistentStoreHelper.createAdBreak()
        ContentCellSetupHelper.setup(contentCell: contentCell,
            contentPreviewProvider: previewViewProvider,
            contentCellDelegate: testContentCellDelegate,
            detailDelegate: testDetailDelegate,
            videoPreviewViewDelegate: testVideoPreviewViewDelegate,
            adBreak: adBreak)
        XCTAssertEqual(0, testVideoPlayer.playFromStartCallCount)
        XCTAssertNotNil(contentCell.adVideoPlayerViewController)
    }

    func testPlayVideo() {
        XCTAssertEqual(0, testVideoPlayer.playFromStartCallCount)
        ContentCellSetupHelper.setup(contentCell: contentCell,
            contentPreviewProvider: previewViewProvider,
            contentCellDelegate: testContentCellDelegate,
            detailDelegate: testDetailDelegate,
            videoPreviewViewDelegate: testVideoPreviewViewDelegate,
            adBreak: nil)
        XCTAssertEqual(1, testVideoPlayer.playFromStartCallCount)
        XCTAssertNil(contentCell.adVideoPlayerViewController)
    }
}
