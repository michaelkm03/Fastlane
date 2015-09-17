//
//  LevelBadgeView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit
import Foundation

/// A UIView subclass that draws it's badge and displays the user's level 
/// as two labels: a "LEVEL" label and a number label below it.
class LevelBadgeView: UIView {
    
    let polygon = LevelPolygonView()
    private let container = UIView()
    private var numberHeightConstraint: NSLayoutConstraint!
    private var numberLabelHorizontalConstraints = [NSLayoutConstraint]()
    
    let levelStringLabel = UILabel()
    let levelNumberLabel = UILabel()
    
    /// The insets for the level number label
    var labelInsets = UIEdgeInsetsMake(0, 0, 0, 0) {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /// "Level" label
    var title: String? {
        didSet {
            if let title = title {
                levelStringLabel.text = title
            }
        }
    }
    
    /// Level number
    var levelNumber: String? {
        didSet {
            if let levelNumber = levelNumber {
                levelNumberLabel.text = levelNumber
                self.setNeedsUpdateConstraints()
            }
        }
    }
    
    /// Color of the badge
    var color: UIColor? = UIColor.redColor() {
        didSet {
            if let color = color {
                polygon.fillColor = color
                polygon.setNeedsDisplay()
            }
        }
    }
    
    /// How round the corners should be
    var cornerRadius: CGFloat = 14 {
        didSet {
            polygon.cornerRadius = cornerRadius
        }
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
        
        if let levelNumber = levelNumber {
            if let numberHeightConstraint = numberHeightConstraint {
                levelNumberLabel.removeConstraint(numberHeightConstraint)
            }
            let currentFontSize = levelNumberLabel.font.pointSize
            // Subtract a bit because boundingRectWithSize is inaccurate with large font sizes
            let fontSizeOffset = currentFontSize - currentFontSize * 0.4
            let boundingRect = levelNumber.boundingRectWithSize(CGSize(width: bounds.width, height: CGFloat.max), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes:[NSFontAttributeName : levelNumberLabel.font.fontWithSize(fontSizeOffset)], context:nil)
            numberHeightConstraint = NSLayoutConstraint(item: levelNumberLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: boundingRect.height)
            levelNumberLabel.addConstraint(numberHeightConstraint)
        }
        
        // Remove all width constraints from number label
        for constraint in numberLabelHorizontalConstraints {
            container.removeConstraint(constraint)
        }
        
        // Clear constraints from array
        numberLabelHorizontalConstraints.removeAll()
        
        // Add new constraints to array
        numberLabelHorizontalConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("|-linset-[label]-rinset-|", options: [], metrics: ["linset" : labelInsets.left, "rinset" : labelInsets.right], views: ["label" : levelNumberLabel]))
        
        // Addnew constraints to number label
        for constraint in numberLabelHorizontalConstraints {
            container.addConstraint(constraint)
        }

    }
    
    func sharedInit() {
        
        self.backgroundColor = UIColor.clearColor()
        
        polygon.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(polygon)
        
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
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[polygon]|", options: [], metrics: nil, views: ["polygon" : polygon]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[polygon]|", options: [], metrics: nil, views: ["polygon" : polygon]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[container]|", options: [], metrics: nil, views: ["container" : container]))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: container, attribute: .CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: container, attribute: .CenterY, multiplier: 1, constant: 0))
        
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[label]|", options: [], metrics: nil, views: ["label" : levelStringLabel]))
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[stLabel]-2-[numLabel]|", options: [], metrics: nil, views: ["stLabel" : levelStringLabel, "numLabel" : levelNumberLabel]))
    }
}
