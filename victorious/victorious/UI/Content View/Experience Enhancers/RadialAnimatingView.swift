//
//  RadialAnimatingView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// A view which masks it's layer with a radial animation
class RadialAnimatingView: UIView {
    
    let circleAnimationKey = "animateCircle"
    private let circleLayer = CAShapeLayer()
    
    /// Determines if this view's layer is currently animating
    var isAnimating: Bool {
        return self.circleLayer.animationForKey(self.circleAnimationKey) != nil
    }
    
    var animationCurve: String = kCAMediaTimingFunctionLinear
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    private func sharedInit() {
        self.circleLayer.fillColor = UIColor.clearColor().CGColor
        self.circleLayer.strokeColor = UIColor.whiteColor().CGColor
        self.layer.mask = circleLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Setup circle
        circleLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: CGRectGetWidth(self.bounds) / 2).CGPath
        self.circleLayer.frame = self.bounds
        self.circleLayer.lineWidth = CGRectGetWidth(self.bounds)
        self.circleLayer.masksToBounds = true
        self.layer.mask = self.circleLayer
    }
    
    /// MARK: Public functions
    
    /// Starts the radial animation
    ///
    /// - parameter startValue: A value between 0 and 1 determining how far around the circumference the animation will begin
    /// - parameter endValue: A value between 0 and 1 determining how far around the circumference the animation will end
    func animate(duration: NSTimeInterval, startValue: CGFloat, endValue: CGFloat) {
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = startValue
        animation.toValue = endValue
        animation.timingFunction = CAMediaTimingFunction(name: animationCurve)
        
        // Set the circleLayer's strokeEnd property to the end value so it remains
        self.circleLayer.strokeEnd = endValue
        self.circleLayer.addAnimation(animation, forKey: self.circleAnimationKey)
    }
    
    func adjustMask(endValue: CGFloat) {
        self.circleLayer.strokeEnd = endValue
    }
    
    /// Removes all animations from this view's layer
    func reset() {
        self.circleLayer.removeAllAnimations()
    }
}
