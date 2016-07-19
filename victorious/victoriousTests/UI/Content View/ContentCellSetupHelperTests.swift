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
    let videoPreviewView: VVideoSequencePreviewView
    var hasRelinquishedPreviewView = false

    init(videoPlayer: VVideoPlayer,
        containterView: UIView = UIView(),
        restorePreviewView: UIView = UIView(),
        videoPreviewView: VVideoSequencePreviewView = VVideoSequencePreviewView()) {
            self.videoPlayer = videoPlayer
            self.containerView = containterView
            self.restorePreviewView = restorePreviewView
            self.videoPreviewView = videoPreviewView
            super.init()
    }

    func getPreviewView() -> VSequencePreviewView {
        videoPreviewView.videoPlayer = videoPlayer
        return videoPreviewView
    }

    func restorePreviewView(previewView: VSequencePreviewView) {
    }

    func getContainerView() -> UIView {
        return containerView
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

class TestContentCell: VContentCell, VContentPreviewViewReceiver {
    let testTargetSuperView: UIView
    var testPreviewView: VSequencePreviewView?
    var testVideoPlayer: VVideoPlayer?

    init(test: Bool, targetSuperView: UIView, frame: CGRect) {
        testTargetSuperView = targetSuperView
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getTargetSuperview() -> UIView {
        return testTargetSuperView
    }

    func setPreviewView(previewView: VSequencePreviewView) {
        testPreviewView = previewView
    }

    func setVideoPlayer(videoPlayer: VVideoPlayer) {
        testVideoPlayer = videoPlayer
    }
}

class ContentCellSetupHelperTests: BasePersistentStoreTestCase {
    var testVideoPlayer: TestVideoPlayer!
    var testAdDelegate: TestAdLifecycleDelegate!
    var testDetailDelegate: TestDetailDelegate!
    var testVideoPreviewViewDelegate: TestVideoPreviewViewDelegate!
    var previewViewProvider: TestContentVideoPreviewViewProvider!
    var contentCell: VContentCell!
    var setupHelper: ContentCellSetupHelper!

    override func setUp() {
        super.setUp()
        setupHelper = ContentCellSetupHelper()
        continueAfterFailure = false
        testVideoPlayer = TestVideoPlayer()
        testAdDelegate = TestAdLifecycleDelegate()
        testDetailDelegate = TestDetailDelegate()
        testVideoPreviewViewDelegate = TestVideoPreviewViewDelegate()
        previewViewProvider = TestContentVideoPreviewViewProvider(videoPlayer: testVideoPlayer)
        contentCell = VContentCell()
    }

    func testContentCellSetup() {
        var result = setupHelper.setup(contentCell: contentCell,
            previewViewProvider: previewViewProvider,
            adDelegate: testAdDelegate,
            detailDelegate: testDetailDelegate,
            videoPreviewViewDelegate: testVideoPreviewViewDelegate,
            adBreak: nil)
        XCTAssertEqual(contentCell.minSize.height, VShrinkingContentLayoutMinimumContentHeight)
        guard let contentCellDelegate = contentCell.delegate else {
            XCTFail("Failed to get a delegate of a content cell after setting it up")
            return
        }
        XCTAssert(contentCellDelegate === testAdDelegate)
        XCTAssertEqual(true, previewViewProvider.hasRelinquishedPreviewView)
        guard let detailDelegate = previewViewProvider.getPreviewView().detailDelegate else {
            XCTFail("Failed to get a preview view detail delegate after setting up a content cell")
            return
        }
        XCTAssert(detailDelegate === testDetailDelegate)
        XCTAssert(previewViewProvider.getPreviewView() === result.previewView)
        XCTAssertNotNil(result.videoPlayer)

        let sequence = persistentStoreHelper.createSequence(remoteId: "1")
        let testDependencyManager = VDependencyManager(parentManager: nil, configuration: nil, dictionaryOfClassesByTemplateName: nil)
        let testTargetSuperView = UIView()
        let testContentCell = TestContentCell(test: true, targetSuperView: testTargetSuperView, frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        result = setupHelper.setup(contentCell: testContentCell,
            adDelegate: testAdDelegate,
            detailDelegate: testDetailDelegate,
            videoPreviewViewDelegate: testVideoPreviewViewDelegate,
            adBreak: nil,
            sequence: sequence,
            dependencyManager: testDependencyManager)
        XCTAssert(previewViewProvider.getPreviewView() !== result.previewView)
        guard let streamItem = result.previewView.streamItem else {
            XCTFail("A newly created preview view doesn't have a stream item set up")
            return
        }
        XCTAssertEqual(sequence, streamItem)
        XCTAssertEqual(testTargetSuperView.bounds, result.previewView.frame)
        XCTAssert(testDependencyManager === result.previewView.dependencyManager)
        XCTAssertEqual(VFocusType.Detail, result.previewView.focusType)
    }

    func testPlayingAd() {
        let adBreak = persistentStoreHelper.createAdBreak()
        setupHelper.setup(contentCell: contentCell,
            previewViewProvider: previewViewProvider,
            adDelegate: testAdDelegate,
            detailDelegate: testDetailDelegate,
            videoPreviewViewDelegate: testVideoPreviewViewDelegate,
            adBreak: adBreak)
        XCTAssertEqual(0, testVideoPlayer.playFromStartCallCount)
    }

    func testPlayVideo() {
        XCTAssertEqual(0, testVideoPlayer.playFromStartCallCount)
        setupHelper.setup(contentCell: contentCell,
            previewViewProvider: previewViewProvider,
            adDelegate: testAdDelegate,
            detailDelegate: testDetailDelegate,
            videoPreviewViewDelegate: testVideoPreviewViewDelegate,
            adBreak: nil)
        XCTAssertEqual(1, testVideoPlayer.playFromStartCallCount)
    }
}
