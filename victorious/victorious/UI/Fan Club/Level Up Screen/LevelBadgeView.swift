//
//  LevelBadgeView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit
import Foundation

class LevelBadgeView: UIView {
    
    private let polygon = LevelPolygonView()
    private let container = UIView()
    private let levelStringLabel = UILabel()
    private let levelNumberLabel = UILabel()
    private var numberHeightConstraint: NSLayoutConstraint!
    
    var title: String? {
        didSet {
            if let title = title {
                levelStringLabel.text = title
            }
        }
    }
    
    var levelNumber: String? {
        didSet {
            if let levelNumber = levelNumber {
                levelNumberLabel.text = levelNumber
            }
        }
    }
    
    var color: UIColor? {
        didSet {
            if let color = color {
                polygon.fillColor = color
                polygon.setNeedsDisplay()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
        
        if let levelNumber = levelNumber {
            levelNumberLabel.removeConstraint(numberHeightConstraint)
            let currentFontSize = levelNumberLabel.font.pointSize
            // Subtract a bit because boundingRectWithSize is inaccurate with large font sizes
            let fontSizeOffset = currentFontSize - currentFontSize * 0.25
            let boundingRect = levelNumber.boundingRectWithSize(CGSize(width: bounds.width, height: CGFloat.max), options: .UsesLineFragmentOrigin | .UsesFontLeading, attributes:[NSFontAttributeName : levelNumberLabel.font.fontWithSize(fontSizeOffset)], context:nil)
            numberHeightConstraint = NSLayoutConstraint(item: levelNumberLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: boundingRect.height)
            levelNumberLabel.addConstraint(numberHeightConstraint)
        }
    }
    
    func sharedInit() {
        
        polygon.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(polygon)
        
        levelStringLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        container.addSubview(levelStringLabel)
        levelNumberLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        container.addSubview(levelNumberLabel)
        
        container.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(container)
        
        levelStringLabel.textAlignment = .Center
        levelNumberLabel.textAlignment = .Center
        levelStringLabel.textColor = UIColor.whiteColor()
        levelNumberLabel.textColor = UIColor.whiteColor()
        
        levelStringLabel.font = UIFont.boldSystemFontOfSize(14)
        levelNumberLabel.font = UIFont.boldSystemFontOfSize(60)
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[polygon]|", options: nil, metrics: nil, views: ["polygon" : polygon]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[polygon]|", options: nil, metrics: nil, views: ["polygon" : polygon]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[container]|", options: nil, metrics: nil, views: ["container" : container]))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: container, attribute: .CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: container, attribute: .CenterY, multiplier: 1, constant: 0))
        
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[label]|", options: nil, metrics: nil, views: ["label" : levelStringLabel]))
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[label]|", options: nil, metrics: nil, views: ["label" : levelNumberLabel]))
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[stLabel]-5-[numLabel]|", options: nil, metrics: nil, views: ["stLabel" : levelStringLabel, "numLabel" : levelNumberLabel]))
        numberHeightConstraint = NSLayoutConstraint(item: levelNumberLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 70)
        levelNumberLabel.addConstraint(numberHeightConstraint)
    }
}
