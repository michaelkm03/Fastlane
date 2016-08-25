//
//  Forum+Stage.swift
//  victorious
//
//  Created by Michael Sena on 7/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// Implementors will be notified about the state of the animations.
protocol StageShrinkingAnimatorDelegate: class {
    func willSwitch(to state: StageState)
    func shouldSwtich(to state: StageState) -> Bool
}

/// Describes which state the stage can be in.
enum StageState {
    case enlarged
    case shrunken
}

/// StageShrinkingAnimator is a helper class for animating the stage shrinking interaction.
/// This class performs the animations by modifying the properties:
///
/// * `stageContainer.transform` by applying a combination of scale and translate transform to shrink the stage into the corner.
/// * `stageViewControllerContainmentCOntainer.layer.cornerRadius` by rounding the corner interactively during the animation.
/// * `stageViewControllerContainer.layer.borderColor` by fading the border from clear to white with opacity.
/// 
/// **NOTE:** No constraints are modified or added to the view hierarchy as part of this animator's behavior.
///
class StageShrinkingAnimator: NSObject {

    weak var delegate: StageShrinkingAnimatorDelegate?

    private struct Constants {
        static let downDragIgnoredMagnitude = CGFloat(120)
        static let dragMagnitude = CGFloat(160)
        static let cornerRadius = CGFloat(6)
        static let scaleFactor = CGFloat(0.42666)
        static let shadowRadius = CGFloat(4)
        static let shadowOpacity = Float(0.40)
        static let shadowOffset = CGSize(width:0, height:2)
        static let shadowColor = UIColor.blackColor().CGColor
        static let scaleTransform = CGAffineTransformMakeScale(scaleFactor, scaleFactor)
        static let stageMargin = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 10)
        static let borderEndingAlpha = CGFloat(0.3)
        static let openPanTriggerProgress = CGFloat(0.8)
        static let closePanTriggerProgress = CGFloat (0.25)
        static let velocityTargetShrink = CGFloat(0.3)
        static let velocityTargetGrow = CGFloat(1.5)
        static let inProgressSnapAnimationDuration = NSTimeInterval(0.3)
        static let fullSnapAnimationDuration = NSTimeInterval(0.4)
        static let springDamping = CGFloat(0.72)
        static let inProgressSpringInitialVelocity = CGFloat(0.2)
    }
    
    private var ignoreScrollBehaviorUntilNextBegin = false
    
    private var stageState = StageState.enlarged
    
    // MARK: - Handler Properties

    /// This handler will be called when the animator desires the keyboard to be hidden.
    var shouldHideKeyboardHandler: (() -> Void)?
    
    /// This handler will be called interactively during the animation transition. The progress value passed in the handler could be outside of the 0-1 range.
    var interpolateAlongside: ((progress: CGFloat) -> Void)?
    
    // MARK: - Private Properties
    private let stageContainer: UIView

    /// Blocks touches on the stage so that we can tap to expand
    private let stageTouchView: UIView
    private let stageViewControllerContainer: UIView
    private var keyboardManager: VKeyboardNotificationManager!
    private let stageTapGestureRecognizer = UITapGestureRecognizer()
    private let stagePanGestureRecognizer = UIPanGestureRecognizer()
    
    // MARK: - API

    init(
        stageContainer: UIView,
        stageTouchView: UIView,
        stageViewControllerContainer: UIView,
        delegate: StageShrinkingAnimatorDelegate? = nil
    ) {
        self.stageContainer = stageContainer
        self.stageTouchView = stageTouchView
        self.stageViewControllerContainer = stageViewControllerContainer
        self.delegate = delegate
        super.init()
        
        configureMaskingAndBorders()
        configureShadow()
        configureGestureRecognizers()
        configureKeyboardListener()
    }
    
    func chatFeed(chatFeed: ChatFeed, didScroll scrollView: UIScrollView) {
        guard !ignoreScrollBehaviorUntilNextBegin else {
            return
        }
        
        let translation = scrollView.panGestureRecognizer.translationInView(scrollView)
        guard translation.y > 0 && stageState == .enlarged else {
            return
        }
        applyInterploatedValues(withProgress: min(1, max(0, progressThrough(forTranslation: translation))))
    }
    
    func chatFeed(chatFeed: ChatFeed, willBeginDragging scrollView: UIScrollView) {
        ignoreScrollBehaviorUntilNextBegin = false
    }
    
    func chatFeed(chatFeed: ChatFeed, willEndDragging scrollView: UIScrollView, withVelocity velocity: CGPoint) {
        guard !ignoreScrollBehaviorUntilNextBegin else {
            return
        }
        
        // We only care about the end of a scroll gesture when we're in the .enlarged state
        guard stageState == .enlarged else {
            return
        }
        
        let scrollingDown = velocity.y < 0
        let currentState = stageState
        let translation = scrollView.panGestureRecognizer.translationInView(scrollView)
        let targetState = scrollingDown ? StageState.shrunken : StageState.enlarged
        let progressTranslated = progressThrough(forTranslation: translation)
        
        animateInProgressSnap { 
            // Strong flick takes us to the target
            if progressTranslated > 0.5 {
                self.goTo(.shrunken)
            }
            // If we are past half-way go to target
            else if fabs(velocity.y) > Constants.velocityTargetShrink {
                self.goTo(targetState)
            }
            // Otherwise remain at the current location
            else {
                self.goTo(currentState)
            }
            self.ignoreScrollBehaviorUntilNextBegin = true
        }
    }

    // MARK: - Actions
    
    @objc private func pannedOnStage(gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else {
            assertionFailure("Failed to get pan recognizer view for stage shrinking animator.")
            return
        }
        let translation = gesture.translationInView(view)
        let progress = progressThroughPanOnStage(forTranslation: translation)
        switch gesture.state {
            case .Changed:
                // We only perform animation if the translation matches our current state, and delegate permits the state change
                let shouldShrink = stageState == .enlarged && translation.y < 0 && delegate?.shouldSwtich(to: .shrunken) == true
                let shouldEnlarge = stageState == .shrunken && translation.y > 0 && delegate?.shouldSwtich(to: .shrunken) == true
                
                guard shouldShrink || shouldEnlarge else {
                    return
                }
                
                applyInterploatedValues(withProgress: progress)
            case .Ended:
                animateInProgressSnap(withAnimations: {
                    if (self.stageState == .enlarged) && (progress > Constants.closePanTriggerProgress) {
                        self.goTo(.shrunken)
                    }
                    else if (self.stageState == .shrunken) && (progress < Constants.openPanTriggerProgress) {
                        self.goTo(.enlarged)
                    }
                    else {
                        self.goTo(self.stageState)
                    }
                })
            case .Possible, .Began, .Cancelled, .Failed:
                break
        }
    }
    
    @objc private func tappedOnStage(sender: UITapGestureRecognizer) {
        shouldHideKeyboardHandler?()
        ignoreScrollBehaviorUntilNextBegin = true
        UIView.animateWithDuration(
            Constants.fullSnapAnimationDuration,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0,
            options: [],
            animations: { 
                self.enlargeStage()
            },
            completion:nil
        )
    }
    
    // MARK: - Stage Shrinking Support
    
    private func goTo(state: StageState) {
        NSLog("Going to state: \(state)")
        guard delegate?.shouldSwtich(to: state) == true else {
            return
        }
        
        switch state {
            case .shrunken: shrinkStage()
            case .enlarged: enlargeStage()
        }
    }
    
    private func shrinkStage() {
        delegate?.willSwitch(to: .shrunken)
        applyInterploatedValues(withProgress: 1.0)
        stageTouchView.hidden = false
        stageState = .shrunken
    }
    
    private func enlargeStage() {
        delegate?.willSwitch(to: .enlarged)
        applyInterploatedValues(withProgress: 0)
        stageTouchView.hidden = true
        stageViewControllerContainer.layer.borderColor = UIColor.clearColor().CGColor
        stageState = .enlarged
    }
    
    private func applyInterploatedValues(withProgress progress: CGFloat) {
        guard let transform = affineTransform(forProgress: progress) else {
            return
        }
        stageContainer.transform = transform
        stageViewControllerContainer.layer.cornerRadius = Constants.cornerRadius * progress * (1 / scaleFactor(forProgress: progress))
        stageViewControllerContainer.layer.borderColor = interpolatedBorderColor(forProgress: progress)
        
        interpolateAlongside?(progress: progress)
    }
    
    private func animateInProgressSnap(withAnimations animations:() -> Void) {
        ignoreScrollBehaviorUntilNextBegin = true
        UIView.animateWithDuration(
            Constants.inProgressSnapAnimationDuration,
            delay: 0.0,
            usingSpringWithDamping: Constants.springDamping,
            initialSpringVelocity: Constants.inProgressSpringInitialVelocity,
            options: [],
            animations: animations,
            completion: nil
        )
    }
    
    // MARK: - Math and Interpolation functions
    
    /// This method returns a progress through the pan interaction on top of the stage.
    /// Input for translation.y that results in a value of zero indicate that the stage 
    /// should be fully grown. Input that result in a value of 1 indicate that the stage
    /// should be fully shrunken. The progress will apply a linear interpolation of values
    /// for all input in between.
    private func progressThroughPanOnStage(forTranslation translation: CGPoint) -> CGFloat {
        if stageState == .enlarged && translation.y > 0 {
            return 0
        }
        else if stageState == .shrunken && translation.y <= 0 {
            return 1
        }
        else {
            let progress = max(min(fabs(-translation.y) / Constants.dragMagnitude, 1), 0)
            return stageState == .enlarged ? progress : 1 - progress
        }
    }
    
    private func progressThrough(forTranslation translation: CGPoint) -> CGFloat {
        var adjustedTranslation = translation
        if adjustedTranslation.y < 0 {
            adjustedTranslation.y = min(adjustedTranslation.y + Constants.downDragIgnoredMagnitude, 0)
        }
        return adjustedTranslation.y / Constants.dragMagnitude
    }

    private func interpolatedBorderColor(forProgress progress: CGFloat) -> CGColor {
        let interpolatedAlpha = Constants.borderEndingAlpha * progress
        return UIColor(white: 1.0, alpha: interpolatedAlpha).CGColor
    }
    
    private func affineTransform(forProgress progress: CGFloat) -> CGAffineTransform? {
        guard let translation = translation(forProgress: progress) else {
            return nil
        }
        return CGAffineTransformConcat(scaleTransform(forProgress: progress), translation)
    }
    
    private func scaleTransform(forProgress progress: CGFloat) -> CGAffineTransform {
        let transformScaleFactor = scaleFactor(forProgress: progress)
        return CGAffineTransformMakeScale(transformScaleFactor, transformScaleFactor)
    }
    
    private func scaleFactor(forProgress progress: CGFloat) -> CGFloat {
        return 1 - ((1 - Constants.scaleFactor) * progress)
    }
    
    private func collapsedSize() -> CGSize {
        return CGSizeApplyAffineTransform(stageContainer.bounds.size, scaleTransform(forProgress: 1.0))
    }
    
    private func translation(forProgress progress: CGFloat) -> CGAffineTransform? {
        guard let fullTranslation = fullCollapsedTranslation() else {
            return nil
        }
        return CGAffineTransformMakeTranslation(progress * fullTranslation.width, progress * fullTranslation.height)
    }
    
    private func fullCollapsedTranslation() -> CGSize? {
        let currentWidth = stageContainer.bounds.width
        let currentHeight = stageContainer.bounds.height
        guard currentWidth != 0 && currentHeight != 0 else {
            return nil
        }
        
        let collapsedSize = self.collapsedSize()
        
        let halfFullWidth = currentWidth / 2
        let halfShrunkenWidth = collapsedSize.width / 2
        let shrunkenXTranslation = halfFullWidth - halfShrunkenWidth - Constants.stageMargin.right
        
        let halfFullHeight = currentHeight / 2
        let halfShrunkenHeight = collapsedSize.height / 2
        let shrunkenYTranslation = halfFullHeight - halfShrunkenHeight - Constants.stageMargin.top

        return CGSize(width: shrunkenXTranslation, height: -shrunkenYTranslation)
    }

    // MARK: - Misc
    
    private func configureShadow() {
        stageContainer.layer.shadowColor = Constants.shadowColor
        stageContainer.layer.shadowRadius = Constants.shadowRadius
        stageContainer.layer.shadowOpacity = Constants.shadowOpacity
        stageContainer.layer.shadowOffset = Constants.shadowOffset
    }
    
    private func configureMaskingAndBorders() {
        stageViewControllerContainer.layer.masksToBounds = true
        
        // Want the border to be 1px after scaled transform.
        stageViewControllerContainer.layer.borderWidth = (1 / stageViewControllerContainer.contentScaleFactor)
        stageViewControllerContainer.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    private func configureGestureRecognizers() {
        stageTapGestureRecognizer.addTarget(self, action: #selector(tappedOnStage(_:)))
        stagePanGestureRecognizer.addTarget(self, action: #selector(pannedOnStage(_:)))
        stageTouchView.addGestureRecognizer(stageTapGestureRecognizer)
        stageContainer.addGestureRecognizer(stagePanGestureRecognizer)

        // Setup is in the larger state so hide the blocker.
        stageTouchView.hidden = true
    }
    
    private func configureKeyboardListener() {
        keyboardManager = VKeyboardNotificationManager(
            keyboardWillShowBlock: { [weak self] startFrame, endFrame, animationDuration, animationCurve in
                UIView.animateWithDuration(Constants.fullSnapAnimationDuration,
                    delay: 0,
                    usingSpringWithDamping: Constants.springDamping,
                    initialSpringVelocity: 0,
                    options: [],
                    animations: {
                        self?.goTo(.shrunken)
                    },
                    completion: nil
                )
            },
            willHideBlock: { [weak self] startFrame, endFrame, animationDuration, animationCurve in
                self?.ignoreScrollBehaviorUntilNextBegin = true
            },
            willChangeFrameBlock: nil
        )
    }
}
