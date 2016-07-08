//
//  Forum+Stage.swift
//  victorious
//
//  Created by Michael Sena on 7/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// StageShrinkingAnimator is a helper class for animating the stage shrinking interaction.
/// This class performs the animations by modifying the properties:
///
/// * `stageContainer.transform` by applying a combination of scale and translate transform to shrink the stage into the corner.
/// * `stageViewControllerContainmentCOntainer.layer.cornerRadius` by rounding the corner interactively during the animation.
/// * `stageBlurBackground.layer.cornerRadius` by rounding interactively during the animation just as above.
/// * `stageViewControllerContainmentContainer.layer.borderColor` by fading the border from clear to white with opacity.
/// 
/// **NOTE:** No constraints are modified or added to the view hierarchy as part of this animator's behavior.
///
class StageShrinkingAnimator: NSObject {
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
        static let tranlationTriggerCoefficient = CGFloat(0.3)
        static let velocityTargetShrink = CGFloat(0.3)
        static let velocityTargetGrow = CGFloat(1.5)
        static let inProgressSnapAnimationDuration = NSTimeInterval(0.3)
        static let fullSnapAnimationDuration = NSTimeInterval(0.45)
        static let springDamping = CGFloat(0.85)
        static let inProgressSpringInitialVelocity = CGFloat(0.2)
    }
    
    private enum StageState {
        case expanded
        case shrunken
    }
    
    private var ignoreScrollBehaviorUntilNextBegin = false
    
    private var stageState = StageState.expanded
    
    // MARK: - Handler Properties

    /// This handler will be called when the animator desires the keyboard to be hidden.
    var shouldHideKeyboardHandler: (() -> Void)?
    
    /// This handler will be called interactively during the animation transition. The percentage value passed in the handler could be outside of the 0-1 range.
    var interpolateAlongside: ((percentage: CGFloat) -> Void)?
    
    // MARK: - Private Properties

    private let stageContainer: UIView
    private let stageTouchBlocker: UIView
    private let chatFeedContainer: UIView
    private let stageViewControllerContainmentContainer: UIView
    private let stageBlurBackground: UIVisualEffectView
    private var keyboardManager: VKeyboardNotificationManager!
    private let stageTapGestureRecognizer = UITapGestureRecognizer()
    private let stagePanGestureRecognizer = UIPanGestureRecognizer()
    
    // MARK: - API

    init(
        stageContainer: UIView,
        stageTouchBlocker: UIView,
        chatFeedContainer: UIView,
        stageViewControllerContainmentContainer: UIView,
        stageBlurBackground: UIVisualEffectView
    ) {
        self.stageContainer = stageContainer
        self.stageTouchBlocker = stageTouchBlocker
        self.chatFeedContainer = chatFeedContainer
        self.stageViewControllerContainmentContainer = stageViewControllerContainmentContainer
        self.stageBlurBackground = stageBlurBackground
        super.init()
        
        configureMaskingAndBorders()
        configureShadow()
        stageTapGestureRecognizer.addTarget(self, action: #selector(tappedOnStage(_:)))
        stagePanGestureRecognizer.addTarget(self, action: #selector(pannedOnStage(_:)))
        stageTouchBlocker.addGestureRecognizer(stageTapGestureRecognizer)
        stageContainer.addGestureRecognizer(stagePanGestureRecognizer)
        keyboardManager = VKeyboardNotificationManager(
            keyboardWillShowBlock: { [weak self] startFrame, endFrame, animationDuration, animationCurve in
                UIView.animateWithDuration(Constants.fullSnapAnimationDuration,
                    delay: 0,
                    usingSpringWithDamping: Constants.springDamping,
                    initialSpringVelocity: 0,
                    options: [],
                    animations: { 
                        self?.shrinkStage()
                    }, completion: nil)
            },
            willHideBlock: { [weak self] startFrame, endFrame, animationDuration, animationCurve in
                self?.ignoreScrollBehaviorUntilNextBegin = true
            },
            willChangeFrameBlock: nil
        )
    }
    
    func chatFeed(chatFeed: ChatFeed, didScroll scrollView: UIScrollView) {
        guard ignoreScrollBehaviorUntilNextBegin == false else {
            return
        }
        
        let translation = scrollView.panGestureRecognizer.translationInView(chatFeedContainer)
        guard translation.y > 0 && stageState == .expanded else {
            return
        }
        applyInterploatedValues(withPercentage: min(1, max(0, percentThrough(forTranslation: translation))))
    }
    
    func chatFeed(chatFeed: ChatFeed, didScrollToTop scrollView: UIScrollView) {
        guard ignoreScrollBehaviorUntilNextBegin == false else {
            return
        }
        
        print("scrollToTop")
        UIView.animateWithDuration(Constants.inProgressSnapAnimationDuration) {
            self.shrinkStage()
        }
    }
    
    func chatFeed(chatFeed: ChatFeed, willBeginDragging scrollView: UIScrollView) {
        print("willBeginDragging")
        ignoreScrollBehaviorUntilNextBegin = false
    }
    
    func chatFeed(chatFeed: ChatFeed, willEndDragging scrollView: UIScrollView, withVelocity velocity: CGPoint) {
        guard ignoreScrollBehaviorUntilNextBegin == false else {
            return
        }
        
        let scrollingDown = velocity.y < 0
        guard scrollingDown == true else {
            return
        }
        
        let currentState = stageState
        let translation = scrollView.panGestureRecognizer.translationInView(chatFeedContainer)
        let targetState = scrollingDown ? StageState.shrunken : StageState.expanded
        let percentTranslated = percentThrough(forTranslation: translation)
        print("willEndDragging: velocity: \(velocity), currentState: \(currentState), translation: \(translation), percentTranslated: \(percentTranslated)")
        
        
        UIView.animateWithDuration(0.3) {
            if fabs(velocity.y) > Constants.velocityTargetShrink {
                print("goto target")
                self.goTo(targetState)
            } else if percentTranslated > 0.5 {
                print("goto shrunken")
                self.goTo(.shrunken)
            } else {
                print("goto current")
                self.goTo(currentState)
            }
            self.ignoreScrollBehaviorUntilNextBegin = true
        }
    }

    // MARK: - Actions
    
    @objc private func pannedOnStage(gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else {
            print("something went wrong")
            return
        }
        
        let translation = gesture.translationInView(view)
        switch gesture.state {
            case .Changed:
                // We only care about going a certain direction from either expanded or shrunken
                guard (stageState == .expanded && translation.y < 0 ) || (stageState == .shrunken && translation.y > 0) else {
                    return
                }
                var percentage = max(min(fabs(translation.y) / Constants.dragMagnitude, 1), 0)
                percentage = stageState == .expanded ? percentage : 1 - percentage
                print("translation: \(translation), percentage: \(percentage), startingState: \(stageState)")
                applyInterploatedValues(withPercentage: percentage)
            case .Ended:
                print("ended pan")
                UIView.animateWithDuration(Constants.inProgressSnapAnimationDuration,
                                           delay: 0.0,
                                           usingSpringWithDamping: Constants.springDamping,
                                           initialSpringVelocity: Constants.inProgressSpringInitialVelocity,
                                           options: [],
                                           animations: { 
                                               if gesture.velocityInView(view).y < 0 {
                                                   self.shrinkStage()
                                               } else {
                                                   self.enlargeStage()
                                               }
                                           },
                                           completion: nil)
            case .Possible, .Began, .Cancelled, .Failed:
                break
        }
    }
    
    @objc private func tappedOnStage(sender: UITapGestureRecognizer) {
        shouldHideKeyboardHandler?()
        ignoreScrollBehaviorUntilNextBegin = true
        UIView.animateWithDuration(Constants.fullSnapAnimationDuration,
                                   delay: 0,
                                   usingSpringWithDamping: Constants.springDamping,
                                   initialSpringVelocity: 0,
                                   options: [],
                                   animations: { 
                                       self.enlargeStage()
                                   },
                                   completion:nil)
    }
    
    // MARK: - Stage Shrinking Support
    
    private func goTo(state: StageState) {
        if state == .shrunken {
            shrinkStage()
        }
        else
        {
            enlargeStage()
        }
    }
    
    private func shrinkStage() {
        print("shrink stage")
        applyInterploatedValues(withPercentage: 1.0)
        self.stageTouchBlocker.hidden = false
        stageState = .shrunken
    }
    
    private func enlargeStage() {
        print("enlarge stage")
        applyInterploatedValues(withPercentage: 0)
        self.stageTouchBlocker.hidden = true
        self.stageViewControllerContainmentContainer.layer.borderColor = UIColor.clearColor().CGColor
        stageState = .expanded
    }
    
    private func applyInterploatedValues(withPercentage percentage: CGFloat) {
        stageContainer.transform = affineTransformFor(percentage)
        stageViewControllerContainmentContainer.layer.cornerRadius = Constants.cornerRadius * percentage * (1 / scaleFactorFor(percentage))
        stageBlurBackground.layer.cornerRadius = Constants.cornerRadius * percentage * (1 / scaleFactorFor(percentage))
        stageViewControllerContainmentContainer.layer.borderColor = interpolatedBorderColorFor(percentThrough: percentage)
        interpolateAlongside?(percentage: percentage)
    }
    
    // MARK: - Math and Interpolation functions
    
    private func percentThrough(forTranslation translation: CGPoint) -> CGFloat {
        var adjustedTranslation = translation
        if adjustedTranslation.y < 0 {
            adjustedTranslation.y = min(adjustedTranslation.y + Constants.downDragIgnoredMagnitude, 0)
        }
        var percentTranslated = adjustedTranslation.y / Constants.dragMagnitude
        if percentTranslated <= 0 {
            percentTranslated = 1 - fabs(percentTranslated)
        }
        print("percent translated: \(percentTranslated)")
        return percentTranslated
    }
    
    private func interpolatedBorderColorFor(percentThrough percent: CGFloat) -> CGColor {
        let interpolatedAlpha = Constants.borderEndingAlpha * percent
        return UIColor(white: 1.0, alpha: interpolatedAlpha).CGColor
    }
    
    private func affineTransformFor(percentThrough: CGFloat) -> CGAffineTransform {
        return CGAffineTransformConcat(scaleTransformFor(percentThrough), translationFor(percentThrough))
    }
    
    private func scaleTransformFor(percentThrough: CGFloat) -> CGAffineTransform {
        let scaleFactor = scaleFactorFor(percentThrough)
        return CGAffineTransformMakeScale(scaleFactor, scaleFactor)
    }
    
    private func scaleFactorFor(percentThrough: CGFloat) -> CGFloat {
        return 1 - ((1 - Constants.scaleFactor) * percentThrough)
    }
    
    private func collapsedSize() -> CGSize {
        return CGSizeApplyAffineTransform(stageContainer.bounds.size, scaleTransformFor(1.0))
    }
    
    private func translationFor(percentThrough: CGFloat) -> CGAffineTransform {
        let fullTranslation = fullCollapsedTranslation()
        return CGAffineTransformMakeTranslation(percentThrough * fullTranslation.width, percentThrough * fullTranslation.height)
    }
    
    private func fullCollapsedTranslation() -> CGSize {
        let collapsedSize = self.collapsedSize()
        
        let halfFullWidth = stageContainer.bounds.size.width / 2
        let halfShrunkenWidth = collapsedSize.width / 2
        let shrunkenXTranslation = halfFullWidth - halfShrunkenWidth - Constants.stageMargin.right
        
        let halfFullHeight = stageContainer.bounds.size.height / 2
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
        stageViewControllerContainmentContainer.layer.masksToBounds = true
        stageBlurBackground.layer.masksToBounds = true
        
        // Want the border to be 1px after scaled transform
        stageViewControllerContainmentContainer.layer.borderWidth = (1 / stageViewControllerContainmentContainer.contentScaleFactor)
    }
}
