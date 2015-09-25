//
//  AnimatedBadgeView
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit
import Foundation

/// A UIView subclass that draws it's badge and displays the user's level 
/// as two labels: a "LEVEL" label and a number label below it.
class AnimatedBadgeView: UIView, VHasManagedDependencies {
    
    private let backgroundHexagonView = HexagonView()
    private let animatingHexagonView = HexagonView()
    
    private let container = UIView()
    private var numberHeightConstraint: NSLayoutConstraint!
    
    private lazy var linearGradientView: VLinearGradientView = {
        let linearGradientView = VLinearGradientView()
        linearGradientView.setColors([UIColor.clearColor(), UIColor.blackColor(), UIColor.blackColor(), UIColor.clearColor()])
        linearGradientView.locations = [0.0, 0.2, 0.8, 1.0]
        linearGradientView.startPoint = CGPoint(x: 0, y: 0.5)
        linearGradientView.endPoint = CGPoint(x: 1, y: 0.5)
        return linearGradientView
        }()
    
    let levelStringLabel = UILabel()
    let levelNumberLabel = UILabel()
    
    /// "Level" label
    var title: String? {
        didSet {
            if let title = title {
                levelStringLabel.text = title
            }
        }
    }
    
    /// Level number
    var levelNumberString: String? {
        didSet {
            if let levelNumberString = levelNumberString {
                levelNumberLabel.text = levelNumberString
                self.setNeedsUpdateConstraints()
            }
        }
    }
    
    /// Color of the badge
    var badgeBackgroundColor: UIColor? {
        didSet {
            if let badgeBackgroundColor = badgeBackgroundColor {
                backgroundHexagonView.fillColor = badgeBackgroundColor
                animatingHexagonView.fillColor = badgeBackgroundColor
            }
        }
    }
    
    /// How round the corners should be
    var cornerRadius: CGFloat = 14 {
        didSet {
            backgroundHexagonView.cornerRadius = cornerRadius
            animatingHexagonView.cornerRadius = cornerRadius
        }
    }
    
    /// Color of the progress indicator
    var animatedBorderColor: UIColor? {
        didSet {
            if let animatedBorderColor = animatedBorderColor {
                animatingHexagonView.strokeColor = animatedBorderColor
            }
        }
    }
    
    /// Width of the stroke of the animated inner hexagon
    var animatedBorderWidth: CGFloat = 0 {
        didSet {
            animatingHexagonView.borderWidth = animatedBorderWidth
            self.setNeedsUpdateConstraints()
        }
    }
    
    /// How far the animated progress bar is inset from the background
    var progressBarInset: CGFloat = 0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /// The minimum level it takes to expose this badge view
    private(set) var minLevel = 0
    
    /// A percentage between 0 and 100 representing where the progress indicator currently ends
    private(set) var currentProgressPercentage: Int = 0
    
    /// Whether or not the progress bar is currently being animated
    var isAnimating: Bool {
        return animatingHexagonView.isAnimating
    }
    
    /// Convenience initializer
    required init(dependencyManager: VDependencyManager) {
        super.init(frame: CGRectZero)
        sharedInit()
        configureWithDependencyManager(dependencyManager)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
        
        if let levelNumberString = levelNumberString {
            if let numberHeightConstraint = numberHeightConstraint {
                levelNumberLabel.removeConstraint(numberHeightConstraint)
            }
            let currentFontSize = levelNumberLabel.font.pointSize
            // Subtract a bit because boundingRectWithSize is inaccurate with large font sizes
            let fontSizeOffset = currentFontSize - currentFontSize * 0.3
            let boundingRect = String(levelNumberString).boundingRectWithSize(CGSize(width: bounds.width, height: CGFloat.max), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes:[NSFontAttributeName : levelNumberLabel.font.fontWithSize(fontSizeOffset)], context:nil)
            numberHeightConstraint = NSLayoutConstraint(item: levelNumberLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: boundingRect.height)
            levelNumberLabel.addConstraint(numberHeightConstraint)
        }
        
        // Add constraints to progress hexagon view
        animatingHexagonView.removeConstraints(animatingHexagonView.constraints)
        let originalOrigin = animatedBorderWidth / 2
        let insetOrigin = originalOrigin + progressBarInset
        self.v_addFitToParentConstraintsToSubview(animatingHexagonView, leading: insetOrigin, trailing: insetOrigin, top: insetOrigin, bottom: insetOrigin)
    }
    
    func sharedInit() {
        
        backgroundColor = UIColor.clearColor()
        
        title = NSLocalizedString("LEVEL", comment: "")
        
        backgroundHexagonView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundHexagonView)
        v_addFitToParentConstraintsToSubview(backgroundHexagonView)
        
        addSubview(animatingHexagonView)
        
        levelStringLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(levelStringLabel)
        levelNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(levelNumberLabel)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        
        levelStringLabel.textAlignment = .Center
        levelNumberLabel.textAlignment = .Center
        
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[label]|", options: [], metrics: nil, views: ["label" : levelStringLabel]))
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[label]|", options: [], metrics: nil, views: ["label" : levelNumberLabel]))
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[stLabel][numLabel]|", options: [], metrics: nil, views: ["stLabel" : levelStringLabel, "numLabel" : levelNumberLabel]))
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[container]|", options: [], metrics: nil, views: ["container" : container]))
        v_addCenterToParentContraintsToSubview(container)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        linearGradientView.frame = container.bounds
    }
    
    /// MARK: Public Functions
    
    /// Starts the radial animation of the inner hexagon
    ///
    /// - parameter startValue: A value between 0 and 1 determining how far around the circumference the animation will begin
    /// - parameter endValue: A percentage between 0 and 100 indicating how far the progress bar should animate
    /// - parameter completion: A closure to be called after the animation completes
    func animateProgress(duration: NSTimeInterval, endPercentage: Int, completion: (() -> Void)?) {
        currentProgressPercentage = endPercentage
        animatingHexagonView.animateBorder(CGFloat(endPercentage) / 100.0, duration: duration, completion: completion)
    }
    
    /// Resets progress bar back to zero
    func resetProgress(animated: Bool = false) {
        UIView.animateWithDuration(0.8, animations: { () in
            self.animatingHexagonView.alpha = 0
            }) { (completed) in
                self.currentProgressPercentage = 0
                self.animatingHexagonView.reset()
                self.animatingHexagonView.alpha = 1
        }
    }
    
    /// Updates the level number label with a carousal animation
    ///
    /// - parameter newLevel: A string with which to update the level number label
    func levelUp(newLevel: String) {
        
        // Sets the gradient mask
        container.maskView = linearGradientView
        
        UIView.animateWithDuration(0.7,
            delay: 0,
            options: .CurveEaseIn,
            animations: { () in
                
                self.levelNumberLabel.transform = CGAffineTransformMakeTranslation(-self.levelNumberLabel.bounds.width, 0)
                
            }) { (completed) in
                
                self.levelNumberLabel.transform = CGAffineTransformMakeTranslation(self.levelNumberLabel.bounds.width, 0)
                self.levelNumberString = newLevel
                
                UIView.animateWithDuration(0.7,
                    delay: 0,
                    options: .CurveEaseOut,
                    animations: { () in
                        
                        self.levelNumberLabel.transform = CGAffineTransformIdentity
                        
                    }) { (completed) in
                        
                        // Resets gradient mask
                        self.container.maskView = nil
                }
        }
    }
    
    /// MARK: Helpers
    
    private func configureWithDependencyManager(dependencyManager: VDependencyManager?) {
        guard let dependencyManager = dependencyManager else {
            return
        }
        
        minLevel = dependencyManager.numberForKey("minLevel").integerValue
        badgeBackgroundColor = dependencyManager.colorForKey(VDependencyManagerAccentColorKey)
        animatedBorderColor = dependencyManager.colorForKey(VDependencyManagerSecondaryAccentColorKey)
        levelNumberLabel.textColor = dependencyManager.colorForKey(VDependencyManagerMainTextColorKey)
        levelStringLabel.textColor = dependencyManager.colorForKey(VDependencyManagerMainTextColorKey)
    }
}
