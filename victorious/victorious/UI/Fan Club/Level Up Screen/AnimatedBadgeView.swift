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
    var color: UIColor? = UIColor.redColor() {
        didSet {
            if let color = color {
                backgroundHexagonView.fillColor = color
                animatingHexagonView.fillColor = color
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
    var animatedBorderColor: UIColor? = UIColor.whiteColor() {
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
    
    /// A value between 0 and 1 representing where the progress indicator currently ends
    private(set) var currentProgress: CGFloat = 0
    
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
            let fontSizeOffset = currentFontSize - currentFontSize * 0.4
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
        
        self.backgroundColor = UIColor.clearColor()
        
        backgroundHexagonView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(backgroundHexagonView)
        
        self.addSubview(animatingHexagonView)
        
        levelStringLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(levelStringLabel)
        levelNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(levelNumberLabel)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(container)
        
        levelStringLabel.textAlignment = .Center
        levelNumberLabel.textAlignment = .Center
        levelStringLabel.textColor = UIColor.whiteColor()
        levelNumberLabel.textColor = UIColor.whiteColor()
        
        levelStringLabel.font = UIFont.boldSystemFontOfSize(14)
        levelNumberLabel.font = UIFont.boldSystemFontOfSize(60)
        
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[label]|", options: [], metrics: nil, views: ["label" : levelStringLabel]))
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[label]|", options: [], metrics: nil, views: ["label" : levelNumberLabel]))
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[stLabel]-2-[numLabel]|", options: [], metrics: nil, views: ["stLabel" : levelStringLabel, "numLabel" : levelNumberLabel]))
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[hexagonView]|", options: [], metrics: nil, views: ["hexagonView" : backgroundHexagonView]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[hexagonView]|", options: [], metrics: nil, views: ["hexagonView" : backgroundHexagonView]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[container]|", options: [], metrics: nil, views: ["container" : container]))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: container, attribute: .CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: container, attribute: .CenterY, multiplier: 1, constant: 0))
    }
    
    /// MARK: Public Functions
    
    /// Starts the radial animation of the inner hexagon
    ///
    /// - parameter startValue: A value between 0 and 1 determining how far around the circumference the animation will begin
    /// - parameter endValue: A value between 0 and 1 determining how far around the circumference the animation will end
    func animateProgress(duration: NSTimeInterval, endValue: CGFloat) {
        currentProgress = endValue
        animatingHexagonView.animateBorder(endValue, duration: duration)
    }
    
    /// Resets progress bar back to zero
    func resetProgress() {
        currentProgress = 0
        animatingHexagonView.reset()
    }
    
    /// MARK: Helpers
    
    private func configureWithDependencyManager(dependencyManager: VDependencyManager?) {
        if let dependencyManager = dependencyManager {
            minLevel = dependencyManager.numberForKey("minLevel").integerValue
            color = dependencyManager.colorForKey(VDependencyManagerAccentColorKey)
            animatedBorderColor = dependencyManager.colorForKey(VDependencyManagerSecondaryAccentColorKey)
            levelNumberLabel.textColor = dependencyManager.colorForKey(VDependencyManagerMainTextColorKey)
            levelStringLabel.textColor = dependencyManager.colorForKey(VDependencyManagerMainTextColorKey)
        }
    }
}
