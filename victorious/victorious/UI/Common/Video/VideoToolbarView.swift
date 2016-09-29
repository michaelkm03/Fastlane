//
//  VideoToolbarView.swift
//  victorious
//
//  Created by Patrick Lynch on 9/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// Defines an objec that can respond to UI and playback events that occur in a `VVideoToolbarView`
@objc protocol VideoToolbarDelegate {
    
    @objc optional func animateAlongsideVideoToolbarWillAppear( _ videoToolbar: VideoToolbarView )
    @objc optional func animateAlongsideVideoToolbarWillDisappear( _ videoToolbar: VideoToolbarView )
    
    func videoToolbar( _ videoToolbar: VideoToolbarView, didScrubToLocation location: Float )
    func videoToolbar( _ videoToolbar: VideoToolbarView, didStartScrubbingToLocation location: Float )
    func videoToolbar( _ videoToolbar: VideoToolbarView, didEndScrubbingToLocation location: Float )
    func videoToolbarDidPause( _ videoToolbar: VideoToolbarView )
    func videoToolbarDidPlay( _ videoToolbar: VideoToolbarView )
}

/// A generic video toolbar with controls for play, pause, seek (scrub), timeline and current time text.
class VideoToolbarView: UIView {
    
    weak var delegate: VideoToolbarDelegate?
    
    fileprivate var autoVisibilityTimer = VTimerManager()
    
    fileprivate let kTimeLabelPlaceholderText = "--:--"
    fileprivate let kPlayButtonPlayImageName = "player-play-icon"
    fileprivate let kPlayButtonPauseImageName = "player-pause-icon"
    
    fileprivate let kVisibilityAnimationDuration = 0.2
    fileprivate let kMaxVisibilityTimerDuration = 4.0
    
    @IBOutlet fileprivate weak var playButton: UIButton!
    @IBOutlet fileprivate weak var slider: UISlider!
    @IBOutlet fileprivate weak var elapsedTimeLabel: UILabel!
    @IBOutlet fileprivate weak var remainingTimeLabel: UILabel!
    @IBOutlet fileprivate weak var containerView: UIView!
    
    @IBOutlet fileprivate weak var containerTopConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var containerBottomConstraint: NSLayoutConstraint!
    
    fileprivate var isSliderDown: Bool = false
    fileprivate lazy var timeFormatter = VElapsedTimeFormatter()
    fileprivate var lastInteractionDate = Date()
    
    func resetTime() {
        self.elapsedTimeLabel.text = kTimeLabelPlaceholderText
        self.remainingTimeLabel.text = kTimeLabelPlaceholderText
        slider.value = 0.0
    }
    
    func setCurrentTime( _ timeSeconds: Float64, duration: Float64 ) {
        slider.value = clampRatio( Float(timeSeconds / duration) )
        elapsedTimeLabel.text = self.timeFormatter.string(forSeconds: clampTime(timeSeconds) )
        remainingTimeLabel.text = self.timeFormatter.string(forSeconds: clampTime(duration - timeSeconds) )
    }
    
    func setProgress( _ progress: Float, duration: Float64 ) {
        slider.value = clampRatio( progress )
        let elapsedTime = Float64(progress) * duration
        elapsedTimeLabel.text = self.timeFormatter.string(forSeconds: clampTime(elapsedTime) )
        remainingTimeLabel.text = self.timeFormatter.string(forSeconds: clampTime(duration - elapsedTime) )
    }
    
    var paused: Bool = true {
        didSet {
            let imageName = paused ? kPlayButtonPlayImageName : kPlayButtonPauseImageName
            let image = UIImage(named: imageName)!
            playButton.setImage( image, for: UIControlState() )
        }
    }
    
    fileprivate(set) var isVisible = true
    
    var autoVisibilityTimerEnabled = true {
        didSet {
            if self.autoVisibilityTimerEnabled {
                resetTimer()
            }
            else {
                autoVisibilityTimer.invalidate()
            }
        }
    }
    
    // MARK: - Initialization
    
    static func viewFromNib() -> VideoToolbarView {
        return VideoToolbarView.v_fromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        paused = true
        setVisible(false, animated: false)
        resetTime()
    }
    
    // MARK: - Visibility
    
    func setVisible(_ isVisible: Bool, animated: Bool = true) {
        guard isVisible != self.isVisible else {
            return
        }
        
        self.isVisible = isVisible
        
        layoutIfNeeded()
        
        let animations = {
            self.containerTopConstraint.constant = isVisible ? 0.0 : self.frame.height
            self.containerBottomConstraint.constant = isVisible ? 0.0 : -self.frame.height
            self.layoutIfNeeded()
            
            if isVisible {
                self.delegate?.animateAlongsideVideoToolbarWillAppear?(self)
            }
            else {
                self.delegate?.animateAlongsideVideoToolbarWillDisappear?(self)
            }
        }
        
        let completion: (Bool) -> Void = { finished in
            if isVisible {
                if self.autoVisibilityTimerEnabled {
                    self.resetTimer()
                }
            }
            else {
                self.autoVisibilityTimer.invalidate()
            }
        }
        
        if animated {
            UIView.animate(
                withDuration: kVisibilityAnimationDuration,
                delay: 0.0,
                options: .curveEaseOut,
                animations: animations,
                completion: completion
            )
        }
        else {
            animations()
            completion(true)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction fileprivate func onSliderDown( _ slider: UISlider ) {
        isSliderDown = true
        refreshVisibilityDate()
        delegate?.videoToolbar( self, didStartScrubbingToLocation: slider.value)
    }
    
    @IBAction fileprivate func onSliderUp( _ slider: UISlider ) {
        isSliderDown = false
        refreshVisibilityDate()
        delegate?.videoToolbar( self, didEndScrubbingToLocation: slider.value)
    }
    
    @IBAction fileprivate func onSliderValueChanged( _ slider: UISlider ) {
        if isSliderDown {
            refreshVisibilityDate()
            delegate?.videoToolbar(self, didScrubToLocation: slider.value)
        }
    }
    
    @IBAction fileprivate func onPlayButtonPressed( _ slider: UISlider ) {
        paused = !paused
        if paused {
            delegate?.videoToolbarDidPause( self )
        }
        else {
            delegate?.videoToolbarDidPlay( self )
        }
        refreshVisibilityDate()
    }
    
    // MARK: - Helpers
    
    fileprivate func clampTime( _ time: Float64 ) -> Float64 {
        return time < 0.0 ? 0.0 : time
    }
    
    fileprivate func clampRatio( _ time: Float ) -> Float {
        return time < 0.0 ? 0.0 : time > 1.0 ? 1.0 : time
    }
    
    func onTimer() {
        let duration = -self.lastInteractionDate.timeIntervalSinceNow
        if duration >= kMaxVisibilityTimerDuration {
            autoVisibilityTimer.invalidate()
            setVisible(false, animated: true)
        }
    }
    
    fileprivate func refreshVisibilityDate() {
        self.lastInteractionDate = Date()
    }
    
    fileprivate func resetTimer() {
        if !self.autoVisibilityTimerEnabled {
            return
        }
        autoVisibilityTimer.invalidate()
        refreshVisibilityDate()
        autoVisibilityTimer = VTimerManager.scheduledTimerManager(
            withTimeInterval: 0.5,
            target: self,
            selector: #selector(onTimer),
            userInfo: nil,
            repeats: true
        )
    }
}
