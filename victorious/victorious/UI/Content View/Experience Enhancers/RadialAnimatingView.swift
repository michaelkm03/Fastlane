//
//  RadialAnimatingView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class RadialAnimatingView : UIView {
    
    let circleAnimationKey = "animateCircle"
    private var circleLayer: CAShapeLayer!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    func sharedInit() {
        let circleLayer = CAShapeLayer()
        circleLayer.fillColor = UIColor.clearColor().CGColor
        circleLayer.strokeColor = UIColor.whiteColor().CGColor
        self.layer.mask = circleLayer
        self.circleLayer = circleLayer
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
    
    func animate(duration: NSTimeInterval, startValue: CGFloat, endValue: CGFloat) {
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = startValue
        animation.toValue = endValue
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        // Set the circleLayer's strokeEnd property to the end value so it remains
        self.circleLayer.strokeEnd = endValue
        self.circleLayer.addAnimation(animation, forKey: self.circleAnimationKey)
    }
    
    func reset() {
        self.circleLayer.removeAllAnimations()
    }
    
    func isAnimating() -> Bool {
        if let animation = self.circleLayer.animationForKey(self.circleAnimationKey) {
            return true
        }
        return false
    }
}
