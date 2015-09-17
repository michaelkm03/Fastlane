//
//  ProfileBadgeView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class ProfileBadgeView: LevelBadgeView, VHasManagedDependencies {
    
    private let animatingPolygonView = LevelPolygonView()
    private let radialAnimatingView = RadialAnimatingView()
    
    override var cornerRadius: CGFloat {
        didSet {
            super.cornerRadius = cornerRadius
            animatingPolygonView.cornerRadius = cornerRadius
        }
    }
    
    var borderWidth: CGFloat = 3 {
        didSet {
            animatingPolygonView.borderWidth = borderWidth
        }
    }
    
    var user: VUser? {
        didSet {
            // Do sum
        }
    }
    
    /// The dependency manager used to style this view. Setting will
    /// update all other appearance properties.
    var badgeDependencyManager: VDependencyManager? {
        didSet {
            
        }
    }
    
    // MARK: Initialization
    
    /// Convenience initializer
    required init(dependencyManager: VDependencyManager) {
        super.init(frame: CGRectZero)
        sharedInit()
        self.badgeDependencyManager = dependencyManager
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func sharedInit() {
        super.sharedInit()
        
        // Add radial animation view thats 0.9x the size of our background polygon
        radialAnimatingView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(radialAnimatingView)
        self.insertSubview(radialAnimatingView, aboveSubview: polygon)
        self.addConstraint(NSLayoutConstraint(item: radialAnimatingView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: polygon, attribute: NSLayoutAttribute.Width, multiplier: 0.92, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: radialAnimatingView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: polygon, attribute: NSLayoutAttribute.Height, multiplier: 0.92, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: radialAnimatingView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: polygon, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: borderWidth / 3))
        self.addConstraint(NSLayoutConstraint(item: radialAnimatingView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: polygon, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: borderWidth / 3))
        
        // Add border polygon to radial animating view
        animatingPolygonView.fillColor = UIColor.clearColor()
        self.radialAnimatingView.addSubview(animatingPolygonView)
        self.radialAnimatingView.v_addFitToParentConstraintsToSubview(animatingPolygonView)
        
        // Set insets on number label to account for animating border
        self.labelInsets = UIEdgeInsetsMake(0, 10, 0, 10)
    }
    
    /// Starts the radial animation
    ///
    /// - parameter startValue: A value between 0 and 1 determining how far around the circumference the animation will begin
    /// - parameter endValue: A value between 0 and 1 determining how far around the circumference the animation will end
    func animate(duration: NSTimeInterval, startValue: CGFloat, endValue: CGFloat) {
        self.radialAnimatingView.animate(duration, startValue: startValue, endValue: endValue)
    }
}
