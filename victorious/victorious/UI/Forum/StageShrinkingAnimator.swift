//
//  Forum+Stage.swift
//  victorious
//
//  Created by Michael Sena on 7/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class StageShrinkingAnimator: NSObject {
    
    private struct Constants {
        static let dragMagnitude: CGFloat = 160
        static let cornerRadius: CGFloat = 6
        static let scaleFactor: CGFloat = 0.42666
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Float = 0.40
        static let shadowOffset = CGSize(width:0, height:2)
        static let shadowColor = UIColor.blackColor().CGColor
        static let scaleTransform = CGAffineTransformMakeScale(scaleFactor, scaleFactor)
        static let stageMargin = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 10)
        static let borderEndingAlpha: CGFloat = 0.3
    }
    
    private enum StageState {
        case expanded
        case shrunken
    }
    
    private var ignoreScrollBehaviorUntilNextBegin = false
    
    private var stageState = StageState.expanded
    
    var shouldHideKeyboardHandler: (() -> Void)?
    
    private let stageContainer: UIView
    private let stageTouchBlocker: UIView
    private let chatFeedContainer: UIView
    private let stageViewControllerContainmentContainer: UIView
    private let stageBlurBackground: UIVisualEffectView
    private let stageTapGestureRecognizer: UITapGestureRecognizer
    private var keyboardManager: VKeyboardNotificationManager!
    
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
        self.stageTapGestureRecognizer = UITapGestureRecognizer()
        super.init()
        
        configureMaskingAndBorders()
        configureShadow()
        stageTapGestureRecognizer.addTarget(self, action: #selector(tappedOnStage(_:)))
        stageTouchBlocker.addGestureRecognizer(stageTapGestureRecognizer)
        keyboardManager = VKeyboardNotificationManager(
            keyboardWillShowBlock: { startFrame, endFrame, animationDuration, animationCurve in
                self.shrinkStage()
            },
            willHideBlock: {startFrame, endFrame, animationDuration, animationCurve in
                self.enlargeStage()
            },
            willChangeFrameBlock: {startFrame, endFrame, animationDuration, animationCurve in
        })
    }
    
    private func performAnimated(animationBlock block: () -> Void, duration animationDuration: NSTimeInterval, animationCurve curve: UIViewAnimationCurve) {
        ignoreScrollBehaviorUntilNextBegin = true
        let rawCurve = UInt(curve.rawValue)
        UIView.animateWithDuration(animationDuration,
                                   delay: 0,
                                   options: UIViewAnimationOptions(rawValue: rawCurve << 16),
                                   animations: block, completion: nil)
    }
    
    //MARK: - API
    
    func chatFeed(chatFeed: ChatFeed, didScroll scrollView: UIScrollView) {
        guard ignoreScrollBehaviorUntilNextBegin == false else {
            return
        }
        
        let translation = scrollView.panGestureRecognizer.translationInView(chatFeedContainer)
        guard (translation.y > 0 && stageState == .expanded) || (translation.y < 0 && stageState == .shrunken) else {
            return
        }
        
        var percentTranslated = translation.y / Constants.dragMagnitude
        if percentTranslated < 0 {
            percentTranslated = 1 - fabs(percentTranslated)
        }
        print("percent translated: \(percentTranslated)")
        applyInterploatedValues(withPercentage: min(1, max(0, percentTranslated)))
    }
    
    func chatFeed(chatFeed: ChatFeed, didScrollTopTop scrollView: UIScrollView) {
        guard ignoreScrollBehaviorUntilNextBegin == false else {
            return
        }
        
        print("scrollToTop")
        UIView.animateWithDuration(0.2) { 
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
        
        print("willEndDragging: velocity: \(velocity)")
        let shouldShrink = velocity.y < 0 ? true : false
        let translation = scrollView.panGestureRecognizer.translationInView(chatFeedContainer)
        let shouldAnimate = translation.y > 0 ? (translation.y < Constants.dragMagnitude) : (translation.y > -Constants.dragMagnitude)
        
        if shouldAnimate {
            UIView.animateWithDuration(0.3) {
                if shouldShrink {
                    self.shrinkStage()
                } else {
                    self.enlargeStage()
                }
            }
        } else {
            if shouldShrink {
                self.shrinkStage()
            } else {
                self.enlargeStage()
            }
        }
        
    }
    
    func chatFeed(chatFeed: ChatFeed, didEndDragging scrollView: UIScrollView) {
        print("didEndDragging")
    }
    
    //MARK: - Actions
    
    @objc private func tappedOnStage(sender: UITapGestureRecognizer) {
        shouldHideKeyboardHandler?()
        ignoreScrollBehaviorUntilNextBegin = true
        UIView.animateWithDuration(0.3,
                                   delay: 0,
                                   usingSpringWithDamping: 1,
                                   initialSpringVelocity: 0,
                                   options: [],
                                   animations: { 
                                    self.enlargeStage()
            },
                                   completion:nil)
    }
    
    // MARK: - Stage Shrinking Support
    
    private func shrinkStage() {
        print("shrink stage")
        applyInterploatedValues(withPercentage: 1.0)
        self.stageTouchBlocker.hidden = false
        self.stageTapGestureRecognizer.enabled = true
        stageState = .shrunken
    }
    
    private func enlargeStage() {
        print("enlarge stage")
        applyInterploatedValues(withPercentage: 0)
        self.stageTouchBlocker.hidden = true
        self.stageViewControllerContainmentContainer.layer.borderColor = UIColor.clearColor().CGColor
        stageState = .expanded
    }
    
    func applyInterploatedValues(withPercentage percentage: CGFloat) {
        stageContainer.transform = affineTransformFor(percentage)
        stageViewControllerContainmentContainer.layer.cornerRadius = Constants.cornerRadius * percentage
        stageBlurBackground.layer.cornerRadius = Constants.cornerRadius * percentage
        stageViewControllerContainmentContainer.layer.borderColor = interpolatedBorderColorFor(percentThrough: percentage)
    }
    
    // MARK: - Math and Interpolation functions
    
    private func interpolatedBorderColorFor(percentThrough percent: CGFloat) -> CGColor {
        let interpolatedAlpha = Constants.borderEndingAlpha * percent
        return UIColor.whiteColor().colorWithAlphaComponent(interpolatedAlpha).CGColor
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

    //MARK: - Misc
    
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
        stageViewControllerContainmentContainer.layer.borderWidth = (1 / stageViewControllerContainmentContainer.contentScaleFactor) //* scaleFactorFor(1.0)
    }
}
