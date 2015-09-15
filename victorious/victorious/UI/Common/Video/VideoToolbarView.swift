//
//  VideoToolbarView.swift
//  victorious
//
//  Created by Patrick Lynch on 9/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// Defines an objec that can respond to UI events that occur in a `VVideoToolbarView`
@objc protocol VideoToolbarDelegate {
    
    func videoToolbar( videoToolbar: VideoToolbarView, didScrubToLocation location: Float )
    func videoToolbar( videoToolbar: VideoToolbarView, didStartScrubbingToLocation location: Float )
    func videoToolbar( videoToolbar: VideoToolbarView, didEndScrubbingToLocation location: Float )
    func videoToolbarDidPause( videoToolbar: VideoToolbarView )
    func videoToolbarDidPlay( videoToolbar: VideoToolbarView )
}


/// A generic video toolbar with controls for play, pause, seek (scrub), timeline and current time text.
class VideoToolbarView: UIView {
    
    var delegate: VideoToolbarDelegate?
    
    private var autoVisbilityTimer = NSTimer()
    
    private let kPlayButtonPlayImageName = "player-play-icon"
    private let kPlayButtonPauseImageName = "player-pause-icon"
    private let kVisibilityAnimationDuration = 0.2
    private let kMaxVisibilityTimerDuration = 4.0
    
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var elapsedTimeLabel: UILabel!
    @IBOutlet private weak var remainingTimeLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    
    @IBOutlet private weak var containerTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var containerBottomConstraint: NSLayoutConstraint!
    
    private var isSliderDown: Bool = false
    private lazy var timeFormatter = VElapsedTimeFormatter()
    private var lastInteractionDate = NSDate()
    
    // MARK: - Properties
    
    var elapsedTime: Float64 = 0.0 {
        didSet {
            let text = self.timeFormatter.stringForSeconds( clampTime(elapsedTime) )
            elapsedTimeLabel.text = text
        }
    }
    
    var remainingTime: Float64 = 0.0 {
        didSet {
            let text = self.timeFormatter.stringForSeconds( clampTime(elapsedTime) )
            remainingTimeLabel.text = text
        }
    }
    
    var paused: Bool = true {
        didSet {
            let imageName = paused ? kPlayButtonPlayImageName : kPlayButtonPauseImageName
            let image = UIImage(named: imageName)!
            playButton.setImage( image, forState: .Normal )
        }
    }
    
    var videoProgressRatio: Float = 0.0 {
        didSet {
            if !isSliderDown {
                slider.value = clampRatio( videoProgressRatio )
            }
        }
    }
    
    private var visible: Bool = true
    var isVisible: Bool {
        return visible
    }
    
    var autoVisbilityTimerEnabled: Bool = true {
        didSet {
            if self.autoVisbilityTimerEnabled {
                resetTimer()
            }
            else {
                autoVisbilityTimer.invalidate()
            }
        }
    }
    
    // MARK: - Initialization
    
    static func viewFromNib() -> VideoToolbarView {
        let nibName = StringFromClass(self)
        let nib = UINib(nibName: nibName, bundle: nil)
        for obj in nib.instantiateWithOwner(nil, options: nil) {
            if let toolbar = obj as? VideoToolbarView {
                return toolbar
            }
        }
        fatalError( "Unable to load VideoToolbarView from nib." )
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.paused = true
        self.hide(animated: false)
    }
    
    // MARK: - Visibility
    
    func hide( animated:Bool = true, withAlongsideAnimations alongsideAnimations: (()->())? = nil ) {
        if !self.visible {
            return
        }
        visible = false
        layoutIfNeeded()
        let animations: ()->() = {
            self.containerTopConstraint.constant = self.frame.height
            self.containerBottomConstraint.constant = -self.frame.height
            self.layoutIfNeeded()
            
            alongsideAnimations?()
        }
        let comletion: Bool->() = { finished in
            self.autoVisbilityTimer.invalidate()
        }
        if animated {
            UIView.animateWithDuration( kVisibilityAnimationDuration,
                delay: 0.0,
                options: .CurveEaseOut,
                animations: animations,
                completion: comletion
            )
        }
        else {
            animations()
            comletion(true)
        }
    }
    
    func show( animated:Bool = true, withAlongsideAnimations alongsideAnimations: (()->())? = nil ) {
        if self.visible {
            return
        }
        visible = true
        layoutIfNeeded()
        let animations: ()->() = {
            self.containerTopConstraint.constant = 0.0
            self.containerBottomConstraint.constant = 0.0
            self.layoutIfNeeded()
            
            alongsideAnimations?()
        }
        let comletion: Bool->() = { finished in
            if self.autoVisbilityTimerEnabled {
                self.resetTimer()
            }
        }
        if animated {
            UIView.animateWithDuration( kVisibilityAnimationDuration,
                delay: 0.0,
                options: .CurveEaseOut,
                animations: animations,
                completion: comletion
            )
        }
        else {
            animations()
            comletion(true)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction private func onSliderDown( slider: UISlider ) {
        isSliderDown = true
        refreshVisibilityDate()
        delegate?.videoToolbar( self, didStartScrubbingToLocation: slider.value)
    }
    
    @IBAction private func onSliderUp( slider: UISlider ) {
        isSliderDown = false
        refreshVisibilityDate()
        delegate?.videoToolbar( self, didEndScrubbingToLocation: slider.value)
    }
    
    @IBAction private func onSliderValueChanged( slider: UISlider ) {
        if isSliderDown {
            refreshVisibilityDate()
            delegate?.videoToolbar(self, didScrubToLocation: slider.value)
        }
    }
    
    @IBAction private func onPlayButtonPressed( slider: UISlider ) {
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
    
    private func clampTime( time: Float64 ) -> Float64 {
        return time < 0.0 ? 0.0 : time
    }
    
    private func clampRatio( time: Float ) -> Float {
        return time < 0.0 ? 0.0 : time > 1.0 ? 1.0 : time
    }
    
    func onTimer() {
        let duration = -self.lastInteractionDate.timeIntervalSinceNow
        if duration >= kMaxVisibilityTimerDuration {
            autoVisbilityTimer.invalidate()
            hide(animated: true)
        }
    }
    
    private func refreshVisibilityDate() {
        self.lastInteractionDate = NSDate()
    }
    
    private func resetTimer() {
        if !self.autoVisbilityTimerEnabled {
            return
        }
        autoVisbilityTimer.invalidate()
        refreshVisibilityDate()
        autoVisbilityTimer = NSTimer.scheduledTimerWithTimeInterval( 0.5,
            target: self,
            selector: "onTimer",
            userInfo: nil,
            repeats: true )
    }
}
