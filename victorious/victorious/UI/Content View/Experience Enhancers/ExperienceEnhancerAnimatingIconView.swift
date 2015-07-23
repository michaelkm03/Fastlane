//
//  ExperienceEnhancerAnimatingIconView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class ExperienceEnhancerAnimatingIconView : UIView {
    
    private var radialAnimatingView: RadialAnimatingView!
    private var backgroundEBView: ExperienceEnhancerIconView!
    private var foregroundEBView: ExperienceEnhancerIconView!
    
    var iconImage : UIImage? {
        didSet {
            self.backgroundEBView.iconImage = iconImage
            self.foregroundEBView.iconImage = iconImage
        }
    }
    
    var overlayImage : UIImage? {
        didSet {
            self.backgroundEBView.overlayImage = overlayImage
            self.foregroundEBView.overlayImage = overlayImage
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
        
        // Create background icon view
        self.backgroundEBView = ExperienceEnhancerIconView()
        self.backgroundEBView.alpha = 0.3
        self.addSubview(self.backgroundEBView)
        self.v_addFitToParentConstraintsToSubview(self.backgroundEBView)
        
        // Create radial animation view
        self.radialAnimatingView = RadialAnimatingView()
        
        // Create foreground icon view and add it to radial animation view
        self.foregroundEBView = ExperienceEnhancerIconView()
        self.radialAnimatingView.addSubview(self.foregroundEBView)
        self.radialAnimatingView.v_addFitToParentConstraintsToSubview(self.foregroundEBView)
        
        // Add radial animation
        self.addSubview(self.radialAnimatingView)
        self.v_addFitToParentConstraintsToSubview(self.radialAnimatingView)
    }
    
    func animate(duration: NSTimeInterval, startValue: CGFloat, endValue: CGFloat) {
        self.radialAnimatingView.animate(duration, startValue: startValue, endValue: endValue)
    }
    
    func reset() {
        self.radialAnimatingView.reset()
    }
    
    func isAnimating() -> Bool {
        return self.radialAnimatingView.isAnimating()
    }
}