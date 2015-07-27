//
//  ExperienceEnhancerAnimatingIconView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// A emotive ballistic view which displays a radial cooldown animation
class ExperienceEnhancerAnimatingIconView : UIView {
    
    private let radialAnimatingView = RadialAnimatingView()
    private let backgroundEBView = ExperienceEnhancerIconView()
    private var foregroundEBView = ExperienceEnhancerIconView()
    
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
    
    /// Determines if cooldown animation is in process
    var isAnimating: Bool {
        return self.radialAnimatingView.isAnimating
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    private func sharedInit() {
        
        // Create background icon view
        self.backgroundEBView.alpha = 0.3
        self.addSubview(self.backgroundEBView)
        self.v_addFitToParentConstraintsToSubview(self.backgroundEBView)
        
        // Create foreground icon view and add it to radial animation view
        self.foregroundEBView = ExperienceEnhancerIconView()
        self.radialAnimatingView.addSubview(self.foregroundEBView)
        self.radialAnimatingView.v_addFitToParentConstraintsToSubview(self.foregroundEBView)
        
        // Add radial animation
        self.addSubview(self.radialAnimatingView)
        self.v_addFitToParentConstraintsToSubview(self.radialAnimatingView)
    }
    
    /// Starts the radial animation
    ///
    /// :param: `startValue` A value between 0 and 1 determining how far around the circumference the animation will begin
    /// :param: `endValue` A value between 0 and 1 determining how far around the circumference the animation will end
    func animate(duration: NSTimeInterval, startValue: CGFloat, endValue: CGFloat) {
        self.radialAnimatingView.animate(duration, startValue: startValue, endValue: endValue)
    }
    
    /// Removes cooldown animation
    func reset() {
        self.radialAnimatingView.reset()
    }
}