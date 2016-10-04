//
//  TestVideoPlayer.swift
//  victorious
//
//  Created by Alex Tamoykin on 2/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@testable import victorious

class TestVideoPlayer: NSObject, VVideoPlayer {
    var playCallCount = 0
    var playFromStartCallCount = 0
    var pauseCallCount = 0
    var pauseAtStartCallCount = 0
    var timeToSeek: TimeInterval = 0
    var setItem: VVideoPlayerItem?
    var backgroundColor: UIColor?
    var resetCallCount = 0
    var currentTimeMilliseconds: UInt = 0
    var currentTimeSeconds: Float64 = 0
    var durationSeconds: Float64 = 0
    weak var delegate: VVideoPlayerDelegate?
    var isPlaying = false
    var useAspectFit = false
    var muted = false
    var view = UIView()
    var aspectRatio: CGFloat = 0

    func play() {
        playCallCount += 1
    }

    func playFromStart() {
        playFromStartCallCount += 1
    }

    func pause() {
        pauseCallCount += 1
    }

    func pauseAtStart() {
        pauseAtStartCallCount += 1
    }

    func seek(toTimeSeconds timeSeconds: TimeInterval) {
        timeToSeek = timeSeconds
    }

    func setItem(_ item: VVideoPlayerItem) {
        setItem = item
    }

    func update(toBackgroundColor backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
    }

    func reset() {
        resetCallCount += 1
    }
}
