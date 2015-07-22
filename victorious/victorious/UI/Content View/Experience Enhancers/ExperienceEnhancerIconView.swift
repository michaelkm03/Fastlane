//
//  ExperienceEnhancerIconView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class ExperienceEnhancerIconView : UIView {
    
    private var iconImageView: UIImageView!
    private var overlayImageView: UIImageView!
    private var circleLayer: CAShapeLayer!
    
    var iconImage : UIImage? {
        didSet {
            self.iconImageView.image = iconImage;
        }
    }
    
    var overlayImage : UIImage? {
        didSet {
            self.overlayImageView.image = overlayImage;
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    func sharedInit() {
        self.overlayImageView = UIImageView()
        self.overlayImageView.contentMode = UIViewContentMode.ScaleAspectFit;
        self.addSubview(self.overlayImageView)
        self.v_addFitToParentConstraintsToSubview(self.overlayImageView)
        
        self.iconImageView = UIImageView()
        self.iconImageView.contentMode = UIViewContentMode.ScaleAspectFit;
        self.addSubview(self.iconImageView)
        self.v_addFitToParentConstraintsToSubview(self.iconImageView, leading: 0, trailing: 0, top: 5, bottom: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let circleLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(roundedRect: self.iconImageView.frame, cornerRadius: CGRectGetWidth(self.bounds) / 2).CGPath
        circleLayer.fillColor = UIColor.clearColor().CGColor
        circleLayer.strokeColor = UIColor.redColor().CGColor
        circleLayer.lineWidth = 5.0
        // Don't draw the circle initially
        self.overlayImageView.layer.addSublayer(circleLayer)
        self.circleLayer = circleLayer
    }
    
    func animateCircle(duration: NSTimeInterval) {
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        // Set the animation duration appropriately
        animation.duration = duration
        
        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = 1.0
        animation.toValue = 0
        
        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        if let circle = self.circleLayer {
            // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
            // right value when the animation ends.
            circle.strokeEnd = 0
            
            // Do the actual animation
            circle.addAnimation(animation, forKey: "animateCircle")
        }
    }
}
