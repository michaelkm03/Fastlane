//
//  VideoToolbarView.swift
//  victorious
//
//  Created by Patrick Lynch on 9/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

@objc protocol VideoToolbarDelegate {
    func videoToolbar( videoToolbar: VideoToolbarView, didScrubToLocation location: Float )
    func videoToolbarDidPause( videoToolbar: VideoToolbarView )
    func videoToolbarDidPlay( videoToolbar: VideoToolbarView )
}

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
    
    // MARK: - UI Setters
    
    var elapsedTime: Float64 = 0.0 {
        didSet {
            let text = self.timeFormatter.stringForSeconds(self.elapsedTime)
            self.elapsedTimeLabel.text = text
        }
    }
    
    var remainingTime: Float64 = 0.0 {
        didSet {
            let text = self.timeFormatter.stringForSeconds(self.remainingTime)
            self.remainingTimeLabel.text = text
        }
    }
    
    var paused: Bool = true {
        didSet {
            let imageName = self.paused ? kPlayButtonPlayImageName : kPlayButtonPauseImageName
            let image = UIImage(named: imageName)!
            self.playButton.setImage( image, forState: .Normal )
        }
    }
    
    private var visible: Bool = true
    var isVisible: Bool {
        return self.visible
    }
    
    var autoVisbilityTimerEnabled: Bool = true {
        didSet {
            if self.autoVisbilityTimerEnabled {
                self.resetTimer()
            }
            else {
                self.autoVisbilityTimer.invalidate()
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
    
    private func resetTimer() {
        if !self.autoVisbilityTimerEnabled {
            return
        }
        self.autoVisbilityTimer.invalidate()
        self.refreshVisibilityDate()
        self.autoVisbilityTimer = NSTimer.scheduledTimerWithTimeInterval( 0.5,
            target: self,
            selector: "onTimer",
            userInfo: nil,
            repeats: true )
    }

    func onTimer() {
        let duration = -self.lastInteractionDate.timeIntervalSinceNow
        println( "duration = \(duration)" )
        if duration >= kMaxVisibilityTimerDuration {
            self.autoVisbilityTimer.invalidate()
            self.hide(animated: true)
        }
    }
    
    private func refreshVisibilityDate() {
        self.lastInteractionDate = NSDate()
    }
    
    func hide( animated:Bool = true ) {
        if !self.visible {
            return
        }
        self.visible = false
        self.layoutIfNeeded()
        let change: ()->() = {
            self.containerTopConstraint.constant = self.frame.height
            self.containerBottomConstraint.constant = -self.frame.height
            self.layoutIfNeeded()
        }
        if animated {
            UIView.animateWithDuration( kVisibilityAnimationDuration,
                delay: 0.0,
                options: .CurveEaseOut,
                animations: change,
                completion: nil
            )
        }
        else {
            change()
        }
    }
    
    func show( animated:Bool = true ) {
        if self.visible {
            return
        }
        if self.autoVisbilityTimerEnabled {
            self.resetTimer()
        }
        self.visible = true
        self.layoutIfNeeded()
        let change: ()->() = {
            self.containerTopConstraint.constant = 0.0
            self.containerBottomConstraint.constant = 0.0
            self.layoutIfNeeded()
        }
        if animated {
            UIView.animateWithDuration( kVisibilityAnimationDuration,
                delay: 0.0,
                options: .CurveEaseOut,
                animations: change,
                completion: nil
            )
        }
        else {
            change()
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func onSliderDown( slider: UISlider ) {
        self.refreshVisibilityDate()
        self.isSliderDown = true
    }
    
    @IBAction func onSliderUp( slider: UISlider ) {
        self.refreshVisibilityDate()
        self.isSliderDown = false
    }
    
    @IBAction func onSliderValueChanged( slider: UISlider ) {
        if self.isSliderDown {
            self.refreshVisibilityDate()
            self.delegate?.videoToolbar(self, didScrubToLocation: slider.value)
        }
    }
    
    @IBAction func onPlayButtonPressed( slider: UISlider ) {
        self.paused = !self.paused
        if self.paused {
            self.delegate?.videoToolbarDidPause( self )
        }
        else {
            self.delegate?.videoToolbarDidPlay( self )
        }
        self.refreshVisibilityDate()
    }
}
