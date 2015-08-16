//
//  VListShelfContentCoverCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class VListShelfContentCoverCell : VShelfContentCollectionViewCell {
    
    private let overlayView: UIView = UIView()
    private let overlayLabel: UILabel = UILabel()
    private let dividerLineLeft: UIView = UIView()
    private let dividerLineRight: UIView = UIView()
    
    required init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.insertSubview(overlayView, aboveSubview: previewViewContainer)
        contentView.v_addFitToParentConstraintsToSubview(overlayView)
        overlayView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        overlayView.addSubview(dividerLineLeft)
        overlayView.addSubview(dividerLineRight)
        overlayView.addSubview(overlayLabel)
        overlayView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-space-[left(>=12)]-space-[label]-space-[right(>=12)]-space-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: ["space" : 5], views: ["left" : dividerLineLeft, "label" : overlayLabel, "right" : dividerLineRight]))
        
        overlayLabel.numberOfLines = 2
        overlayView.addConstraint(NSLayoutConstraint(item: overlayView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: overlayLabel, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
        
        dividerLineLeft.addConstraint(NSLayoutConstraint(item: dividerLineLeft, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 0.0))
        dividerLineRight.addConstraint(NSLayoutConstraint(item: dividerLineRight, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 0.0))
        
        overlayLabel.textAlignment = NSTextAlignment.Center
        updateOverlayLabel()
    }
    
    override func onStreamItemSet() {
        super.onStreamItemSet()
        overlayLabel.text = streamItem?.name
    }
    
    override func onDependencyManagerSet() {
        super.onDependencyManagerSet()
        updateOverlayLabel()
    }
    
    private func updateOverlayLabel() {
        if let dependencyManager = dependencyManager {
            let color = dependencyManager.seeAllTextColor()
            overlayLabel.textColor = color
            dividerLineLeft.backgroundColor = color
            dividerLineRight.backgroundColor = color
            overlayLabel.font = dependencyManager.seeAllFont()
        }
    }
    
}

extension VListShelfContentCoverCell: VStreamCellComponentSpecialization {
    
    override class func reuseIdentifierForStreamItem(streamItem: VStreamItem, baseIdentifier: String?, dependencyManager: VDependencyManager?) -> String {
        return reuseIdentifierForStreamItem(streamItem, baseIdentifier: baseIdentifier, dependencyManager: dependencyManager, className: NSStringFromClass(self))
    }
    
}

private extension VDependencyManager {
    
    func seeAllFont() -> UIFont {
        return self.fontForKey(VDependencyManagerParagraphFontKey)
    }
    
    func seeAllTextColor() -> UIColor {
        return self.colorForKey(VDependencyManagerLinkColorKey)
    }
    
}
